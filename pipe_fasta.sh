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
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":pipe_fasta:"$2":"$3)".log"
echo ${log_file}" "$(date +"%y|%m|%d-%H:%M:%S")
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

#Chosses run mode based on input arguments

NPROC=0
cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
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

ok_log=${log_file/.log/:OK.log}


echo $ok_log
mv $log_file $ok_log

exit 0
