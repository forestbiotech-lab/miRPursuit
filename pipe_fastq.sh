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
trap 'err_report $LINENO $?' ERR




#Name inputs
LIB_FIRST=$1
LIB_LAST=$2
TEMPLATE=$3

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

#Setting up log dir
mkdir -p $workdir"log/"
mkdir -p $workdir"data/fastq"
log_file="${workdir}log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:pipe_fastq:${2}-${3}.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"

#Chooses run mode based on input arguments
echo $(date +"%y/%m/%d-%H:%M:%S")" - Extracting / Copying fastq files to workdir." 
if [[ -z $2 || -z $3 ]]; then
  #Only one argument was given
  CONVERT_LIB=$LCSCIENCE_LIB  #From config file?
  LIB=$LIB_FIRST   
  cp $CONVERT_LIB ${workdir}data/fastq/Lib${LIB}.fq &
  ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB}
else
  #Running various threads      
  NPROC=0
  cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
  for i in $cycle
  do 
    LIB_NOW=$i
    LIB=$(printf "%02d\n"  $LIB_NOW)

    #Test if "fq exists"
    if [[ -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fq|fastq)+$") ]]; then
      #Test if .fastq/fq.gz exists      
      if [[ ! -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fq|fastq)+\.gz$") ]]; then
        CONVERT_LIB=$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fq|fastq)+\.gz$")
        archive="${INSERTS_DIR}/${CONVERT_LIB}"
         if [[ -e "${archive}" ]]; then
           NPROC=$(( $NPROC + 1 ))
           gunzip -c ${archive} > ${workdir}data/fastq/Lib${LIB}.fq &       
         else
           >&2 echo "Terminating. No files or multiple files found using: ${TEMPLATE}\n The current files are: ${archive}" 
           exit 1
         fi
      else
        >&2 echo -ne "${red}Terminated${NC} - No files for lib ${LIB} found in: ${INSERTS_DIR}\nTry using a different sequence of libraries or try a new pattern to select libraries."
        exit 1   
      fi
    else
        if [[ -e $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fq|fastq)+$") ]];then      
            fastq=${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fq|fastq)+$")
            NPROC=$(( $NPROC+1 ))
            cp ${fastq} ${workdir}data/fastq/Lib${LIB}.fq &
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
      mkdir -p ${workdir}data/quality
      fastqc -o ${workdir}data/quality ${workdir}data/fastq/Lib${LIB}.fq   
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
