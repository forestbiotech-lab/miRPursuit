#!/usr/bin/env bash

# pipe_filter_wbench.sh
# 
#
# Created by Andreas Bohn on 31/10/2014.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Modified by Bruno Costa on 22/05/2015
# Call: pipe_filter_wbench.sh [LIB_FIRST] [LIB_LAST] [FILTER_WB_SUFFIX]

LIB_FIRST=$1
LIB_LAST=$2
WB_FILT=$3

#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get workpath variables
. $DIR/config/workdirs.cfg


# define log file
log_file=${workdir}"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":filters:"$1":"$2)".log"
#echo ${log_file}
exec >&1 > ${log_file}

SCRIPT_DIR=${DIR}"/scripts/"
FASTA_DIR=${workdir}"data/fasta/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	${SCRIPT_DIR}filter_wbench.sh ${FASTA_DIR}"lib"$LIB".fa" ${WB_FILT} ${workdir} ${DIR}
  echo "Ran this command: "${SCRIPT_DIR}filter_wbench.sh ${FASTA_DIR}"lib"$LIB".fa" ${WB_FILT} ${workdir} ${DIR}
done
#wait for all threads to finish before continuing.
wait

ok_log=${log_file/.log/:OK.log}
echo $(basename $ok_log)
mv $log_file $ok_log
echo "Processed with filter "$WB_FILT"\n Using"$MAXPROC " cores"

exit 0
