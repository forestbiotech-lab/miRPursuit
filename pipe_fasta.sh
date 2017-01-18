#!/usr/bin/env bash

# pipe_fasta.sh
#
#
# Created by Bruno Costa on 09/11/2015
# Copyright 2015 ITQB / UNL. All rights reserved.
# Copies fasta files to fasta folder to start work
# 
# Call: pipe_fasta.sh [Lib_first] [Lib_last] [template]
#

#Important if this script fails do not continue.
set -e

LIB_FIRST=$1
LIB_LAST=$2
TEMPLATE=$3


#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

#Setting up log dir
mkdir -p $workdir"log/"
mkdir -p $workdir"data/fasta"
log_file=$workdir"log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:pipe_fasta:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file}) 
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

#Chosses run mode based on input arguments

NPROC=0
cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
printf $(date +"%y/%m/%d-%H:%M:%S")" - Copying all fasta files to workdir\n"
for i in $cycle
do
  LIB_NOW=$i
  LIB=$(printf "%02d\n"  $LIB_NOW)
  #Might have problems with well numbers files such as 01 or so.
  EXTRACT_LIB=$(ls ${INSERTS_DIR}/*${TEMPLATE}${LIB_NOW}*.fa)
  NPROC=$(($NPROC+1))
  cp $EXTRACT_LIB ${workdir}data/fasta/lib${LIB}.fa &
  if [ "$NPROC" -ge "$THREADS" ]; then
    wait
    NPROC=0
  fi
done
wait  
printf $(date +"%y/%m/%d-%H:%M:%S")" - Copied all fasta files\n"

#Test fastqc is installed  
installedFastQC="TRUE"
prog=fastqc
command -v $prog >/dev/null 2>&1 || { echo >&2 "${prog} required. Or not in path yet."; installedFastQC="FALSE"; }
if [[ "$installedFastQC" == "TRUE" ]]; then 
  for i in $cycle
  do 
    LIB_NOW=$i
    LIB=$(printf "%02d\n"  $LIB_NOW)
    #Not running in parallel should it? Needs testing
    mkdir -p ${workdir}data/quality
    fastqc -o ${workdir}data/quality ${workdir}data/lib${LIB}.fa   
  done 
else
  printf $(date +"%y/%m/%d-%H:%M:%S")" -FastQC isn't installed will continue without quality control \n" 
fi






ok_log=${log_file/.log/:OK.log}

mv $log_file $ok_log

duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\nUsing ${THREADS} threads.\n"
echo $(basename $ok_log)

exit 0
