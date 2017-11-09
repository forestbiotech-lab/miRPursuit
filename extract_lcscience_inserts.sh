#!/usr/bin/env bash

# extract_lcscience_inserts.sh
# 
#
# Created by Bruno Costa on 21/05/2105
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# Call: extract_lcscience_inserts.sh [LIB_FIRST] [LIB_LAST] [TEMPLATE]

#Name inputs
#LIB=$1
set -e
LIB_FIRST=$1
LIB_LAST=$2
TEMPLATE=$3

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"


#Setting up log dir
mkdir -p $workdir"/log/"
log_file=$workdir"/log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:fastq_to_fasta_LC:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

#Chosses run mode based on input arguments
if [[ -z $2 || -z $3 ]]; then
  EXTRACT_LIB=$LCSCIENCE_LIB
  LIB=$LIB_FIRST
  ${SCRIPT_DIR}extract_lcscience.sh ${DIR} ${LIB} ${EXTRACT_LIB}
  ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB}
  ${SCRIPT_DIR}trim-lcscience.sh ${DIR} ${LIB} 
  
else

  #Running various threads      
  NPROC=0
  cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
  for i in $cycle
  do 
    LIB_NOW=$i
    LIB=$(printf "%02d\n"  $LIB_NOW)
    EXTRACT_LIB=$(ls ${INSERTS_DIR}/*${TEMPLATE}${LIB}*)
    NPROC=$(($NPROC+1))
    ${SCRIPT_DIR}extract_lcscience.sh ${DIR} ${LIB_NOW} ${EXTRACT_LIB} &
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0

  for i in $cycle
  do 
    #Running multiple threads of fq_to_fa_exe.sh
    NPROC=$(($NPROC+1))
    LIB_NOW=$i
    ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB_NOW} &
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0

  for i in $cycle
  do 
    #Paralell threading trim-lcschience.sh
    NPROC=$(($NPROC+1))
    LIB_NOW=$i
    ${SCRIPT_DIR}trim-lcscience.sh ${DIR} ${LIB_NOW} & 
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait

fi

END_TIME=$(date +%s.%N) 
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo "alignment finished in "${DIFF}" secs"


echo "Extracted all libraries"

ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log

exit 0
