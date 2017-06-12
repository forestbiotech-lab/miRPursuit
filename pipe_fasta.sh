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

err_report() {
    >&2 echo "Error -  on line $1 caused a code $2 exit - $3"
    echo "Error -  on line $1 caused a code $2 exit - $3"
}
trap 'err_report $LINENO $?' ERR




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
  #Issues here are if it searches for 1 it might get 11 likewise if it searched for 11 it might get 111 need te strikeout the possibility of a numeral.
  
  #Do fa fasta files exist?
  if [[ -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fa|fasta)+$") ]];then
      #Test if .fastq/fq.gz exists      
      if [[ ! -z $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}*${LIB}*\.(fa|fasta)+\.gz$") ]];then
          EXTRACT_LIB=$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}*${LIB}*\.(fa|fasta)+\.gz$")
          archive="${INSERTS_DIR}/${EXTRACT_LIB}"
          if [[ -e "${archive}" ]]; then
              NPROC=$(( $NPROC + 1 ))
              gunzip -c ${archive} > ${workdir}data/fasta/Lib${LIB}.fa &       
          else
              >&2 echo "Terminating. No files or multiple files found using: ${TEMPLATE}." 
              exit 1
          fi
      else
          >&2 echo "Terminating. No files using template: ${TEMPLATE},in: ${INSERTS_DIR}." 
          exit 1  
      fi
  else
      #Confirm fasta files exist
      if [[ -e $(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fa|fasta)+$") ]];then
          fasta=${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${TEMPLATE}${LIB}.*\.(fa|fasta)+$")
          NPROC=$(($NPROC+1))
          #Change this to set for dynamic threading.
          cp ${fasta} ${workdir}data/fasta/Lib${LIB}.fa &
      else
          >&2 echo "Terminating. ;Multiple files found using template: ${TEMPLATE}, in: ${INSERTS_DIR}." 
          exit 1
      fi
  fi
  if [ "$NPROC" -ge "$THREADS" ]; then
      wait
      NPROC=0
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
