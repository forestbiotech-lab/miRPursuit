#/usr/bin/env bash

# pipe_fastq.sh
# 
#
# Created by Bruno Costa on 18/11/2105
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# Copies fastq files in $INSERTS_DIR to workdir/data/fastq
# and converts files to fasta.
# Single file can be called by name in $LCSCIENCE_LIB IF only one argument is given
#
# Call: pipe_fastq.sh [LIB_FIRST] [LIB_LAST] [TEMPLATE]
# Call: pipe_fastq.sh [LIB_FIRST]

#Important if this script fails do not continue.
set -e

err_report() {
   >&2 echo "Error -  on line $1 caused a code $2 exit - $3"
   echo "Error -  on line $1 caused a code $2 exit - $3"
}
trap 'err_report $LINENO $? $(basename $0)' ERR




#Name inputs
LIB_FIRST=$1
LIB_LAST=$2
TEMPLATE=$3

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

#Setting up log dir
mkdir -p $workdir"/log/"
mkdir -p $workdir"/data/fastq"

SCRIPT_DIR=$DIR"/scripts/"

#Chooses run mode based on input arguments
echo $(date +"%y/%m/%d-%H:%M:%S")" - Extracting / Copying fastq files to workdir." 
#Choses run mode based on input arguments
if [[ -z $2 || -z $3 ]]; then
  if [[ -z $2 ]]; then
    #Only one argument was given

    log_file="${workdir}/log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:pipe_fastq:${1}.log"
    echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})

    exec 2>&1 > ${log_file}
    convert_lib=$LCSCIENCE_LIB  #From config file?
    LIB=$LIB_FIRST   
    cp $convert_lib ${workdir}/data/fastq/Lib${LIB}.fq &
    ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB}
  else  
    #Two arguments were given
    LIB_NOW=$1
    FILE=$2
    LIB=$(printf "%02d\n"  $LIB_NOW)  


    #Log uses input so has to go here.
    log_file=$workdir"/log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:pipe_fastq-$(basename $FILE).log"
    echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file}) 
    exec 2>&1 > ${log_file}

    ##Needs dealing with gz files
    >&2 echo "Copying "$(basename $FILE)"..." 
    cp $FILE ${workdir}/data/fastq/Lib${LIB}.fq  
    >&2 echo "Converting to fasta - "$(basename $FILE)"..."
    ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB_NOW}
  fi
else
  log_file="${workdir}/log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:pipe_fastq:${2}-${3}.log"
  echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
  exec 2>&1 > ${log_file}

  #Running various threads      
  NPROC=0
  cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
  for i in $cycle
  do 
    LIB_NOW=$i
    LIB=$(printf "%00d\n" $LIB_NOW)
    LIB_AFTER=$(printf "%02d\n" $LIB)

    #Test if "fq exists"
    if [[ -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}0*${LIB}[^0-9].*\.*(fq|fastq)+$") ]]; then
      #Test if .fastq/fq.gz exists      
      if [[ ! -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}0*${LIB}[^0-9].*\.*(fq|fastq)+\.gz$") ]]; then
        convert_lib=$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}0*${LIB}[^0-9].*\.*(fq|fastq)+\.gz$")
        archive="${INSERTS_DIR}/${convert_lib}"
         if [[ -f "${archive}" ]]; then
           NPROC=$(( $NPROC + 1 ))
           gunzip -c ${archive} > ${workdir}/data/fastq/Lib${LIB_AFTER}.fq &       
         else
           >&2 echo -ne "Terminating. No files or multiple files found using: ${brown}${TEMPLATE}${NC}\n The current files are: ${brown}${archive}${NC}\n" 
           exit 1
         fi
      else
        >&2 echo -ne "${red}Terminated${NC} - No files for lib ${LIB} found in: ${INSERTS_DIR}\nTry using a different sequence of libraries or try a new pattern to select libraries."
        exit 1   
      fi
    else
        if [[ -f ${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}0*${LIB}[^0-9].*\.*(fq|fastq)+$") ]];then      
            fastq=${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}0*${LIB}[^0-9].*\.*(fq|fastq)+$")
            NPROC=$(( $NPROC+1 ))
            cp ${fastq} ${workdir}/data/fastq/Lib${LIB_AFTER}.fq &
        else
            >&2 echo "Terminating. Multiple files found using template: ${TEMPLATE}, in: ${INSERTS_DIR}" 
            exit 1
        fi
    fi
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0
  printf $(date +"%y/%m/%d-%H:%M:%S")" - Extracted / Copied all fastq files - Quality control. With FastQC\n"

  #Test fastqc is installed  
  installedFastQC="TRUE"
  prog=fastqc
  command -v $prog >/dev/null 2>&1 || { echo >&2 "${prog} required. Or not in path yet"; installedFastQC="FALSE"; }
  if [[ "$installedFastQC" == "TRUE" ]]; then 
    for i in $cycle
    do 
      LIB_NOW=$i
      LIB=$(printf "%02d\n"  $LIB_NOW)
      #Not running in parallel should it? Needs testing
      mkdir -p ${workdir}/data/quality
      fastqc -o ${workdir}/data/quality ${workdir}/data/fastq/Lib${LIB}.fq   
    done 
  else
    printf $(date +"%y/%m/%d-%H:%M:%S")" -FastQC isn't installed will continue without quality control \n" 
  fi

  printf $(date +"%y/%m/%d-%H:%M:%S")" - Starting to convert to fasta PHREAD score is hard-coded to 33\n"
  for i in $cycle
  do 
    #Running multiple threads of fq_to_fa_exe.sh
    NPROC=$(( $NPROC + 1 ))
    LIB_NOW=$i
    LIB=$(printf "%02d\n"  $LIB_NOW)
    ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB_NOW} &
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0
  printf $(date +"%y/%m/%d-%H:%M:%S")" - Finished conversion to fasta for all libs\n"

fi


ok_log=${log_file/.log/:OK.log}


duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\nUsing ${THREADS} threads.\n"
echo $(basename $ok_log)

mv $log_file $ok_log

exit 0
