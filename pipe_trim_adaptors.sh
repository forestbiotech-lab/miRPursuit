#!/usr/bin/env bash

# pipe_trim_adaptors.sh
# 
#
# Created by Bruno Costa on 18/11/2016
# Copyright 2016 ITQB / UNL. All rights reserved.
#
# Call: pipe_trim_adaptors.sh [LIB_FIRST] [LIB_LAST]

#Name inputs
set -e
LIB_FIRST=$1
LIB_LAST=$2

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"


#Setting up log dir
mkdir -p $workdir"log/"
log_file=$workdir"log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:pipe_trim_adaptors:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

#Chosses run mode based on input arguments

printf $(date +"%y/%m/%d-%H:%M:%S")" - Starting adaptor trimming for adaptor: ${ADAPTOR}\n\n"

NPROC=0
cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
for i in $cycle
do 
  #Paralell threading trim-lcschience.sh
  NPROC=$(($NPROC+1))
  LIB_NOW=$i
  printf $(date +"%y/%m/%d-%H:%M:%S")" - Trimming adaptors from Lib${LIB_NOW} fasta\n"
  ${SCRIPT_DIR}trim-adaptors.sh ${DIR} ${LIB_NOW} & 
  if [ "$NPROC" -ge "$THREADS" ]; then 
    wait
    NPROC=0
  fi

done
wait
printf $(date +"%y/%m/%d-%H:%M:%S")" - Trimmed all libraries.\n"

END_TIME=$(date +%s.%N) 
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\n"
printf $(date +"%y/%m/%d-%H:%M:%S")" - Trimming finished in "${DIFF}" secs.\n"

ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log

exit 0