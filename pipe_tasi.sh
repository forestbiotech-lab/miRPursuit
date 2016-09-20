#!/usr/bin/env bash

# pipe_tasi.sh
# 
#
# Created by Bruno Costa on 12/06/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# 
# Call: pipe_filter_wbench.sh [LIB_FIRST] [LIB_LAST]

LIB_FIRST=$1
LIB_LAST=$2

#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get workpath variables
. $DIR/config/workdirs.cfg


#Define log file
log_file=${workdir}"log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:tasi:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec >&1 > ${log_file}

SCRIPTS_DIR=${DIR}"/scripts"
DATA_DIR=${workdir}"data"

#Count execution time
START_TIME=$(date +%s.%N)

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})  
  RUN_TASI=$(echo ${SCRIPTS_DIR}/tasi.sh ${DATA_DIR}"/lib"$LIB"_filt-"*"_mirbase_noncons.fa" ${DIR})
  echo "Ran this command: "
  echo " "$RUN_TASI
  $RUN_TASI

  #This produces a fasta file that may have repeated sequences only use for counting
  awk -F "[(.]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1"("$2")"}}' ${DATA_DIR}"/tasi/lib${LIB}"*"_noncons_tasi_srnas.txt" | sort | uniq | awk -F "[()]" '{print ">"$1"("$2")";newline;print $1}' > "${DATA_DIR}/tasi/lib${LIB}-tasi.fa"

  #awk -F "[(.]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print ">"$1"("$2")";newline;print $1}}' ${DATA_DIR}"/tasi/lib${LIB_NOW}"*"_noncons_tasi_srnas.txt" > "${DATA_DIR}/tasi/lib${LIB_NOW}-tasi.fa"
done
echo $(date +"%y/%m/%d-%H:%M:%S")" - Finished identifying tasi-miRNAs."

END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)

ok_log=${log_file/.log/:OK.log}

duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\n"
printf "Ran in ${SECONDS}secs\n"
echo "Finished in ${DIFF} sec."
echo $(basename $ok_log)
mv $log_file $ok_log

exit 0
