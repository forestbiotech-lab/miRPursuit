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


#Choses run mode based on input arguments

NPROC=0
cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
printf $(date +"%y/%m/%d-%H:%M:%S")" - Copying all fasta files to workdir\n"
for i in $cycle
do
  LIB_NOW=$i
  LIB=$(printf "%02d\n"  $LIB_NOW)  
  EXTRACT_LIB=$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}[0]*${LIB_NOW}.*\.(fa|fasta)+$")


  ##Add gzip extraction
  if [[ -z "$EXTRACT_LIB" ]]; then
      #Test if .fastq/fq.gz exists      
      EXTRACT_LIB=$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}[0]*${LIB_NOW}*\.(fa|fasta)+\.gz$")
      if [[ -e "${INSERTS_DIR}/${EXTRACT_LIB}" ]]; then
        NPROC=$(( $NPROC + 1 ))
        gunzip -c ${INSERTS_DIR}/${EXTRACT_LIB} > ${workdir}data/fasta/Lib${LIB}.fa &       
      else
        >&2 echo "Terminating. No files or multiple files found using: ${TEMPLATE}." 
        exit 1
      fi
  else
    NPROC=$(($NPROC+1))
    #Change this to set for dynamic threading.
    cp ${INSERTS_DIR}/$EXTRACT_LIB ${workdir}data/fasta/Lib${LIB}.fa &
    if [ "$NPROC" -ge "$THREADS" ]; then
      wait
      NPROC=0
    fi
  fi
done
wait  
printf $(date +"%y/%m/%d-%H:%M:%S")" - Copied all fasta files\n"


ok_log=${log_file/.log/:OK.log}

mv $log_file $ok_log

duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\nUsing ${THREADS} threads.\n"
echo $(basename $ok_log)

exit 0
