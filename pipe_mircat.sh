#!/usr/bin/env bash

# pipe_filter_wbench.sh
# 
#
# Created by Bruno Costa on 22/05/2015
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# Call: pipe_filter_wbench.sh [LIB_FIRST] [LIB_LAST]
set -e

LIB_FIRST=$1
LIB_LAST=$2

#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get workpath variables
. $DIR/config/workdirs.cfg


# define log file
log_file="${workdir}/log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID$PPID:mircat:$1:$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec >&1 > ${log_file}

#Set directories
SCRIPTS_DIR=${DIR}"/scripts"
DATA_DIR=${workdir}"/data"


for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
  	echo $(date +"%y/%m/%d-%H:%M:%S")" - Starting to run mircat on: LIB${LIB}"
  	run="${SCRIPTS_DIR}/mircat.sh ${DATA_DIR}/Lib${LIB}_filt"*"_noncons.fa ${DIR}"
  	printf $(date +"%y/%m/%d-%H:%M:%S")" - Ran helper script for micat: \n${run}\n"
  	$run
  	echo $(date +"%y/%m/%d-%H:%M:%S")" - Finished running mircat on: LIB${LIB}"
done


ok_log=${log_file/.log/:OK.log}
duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\n"
echo $(basename $ok_log)
mv $log_file $ok_log

exit 0
