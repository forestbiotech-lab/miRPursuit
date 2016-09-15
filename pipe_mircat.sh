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
log_file=${workdir}"log/"$(echo $(date +"%y|%m|%d-%H:%M:%S")":"$(echo $$)":mircat:"$1":"$2)".log"
echo ${log_file}
exec >&1 > ${log_file}

#Set directories
SCRIPTS_DIR=${DIR}"/scripts"
DATA_DIR=${workdir}"data"

#Count exec time
START_TIME=$(date +%s.%N)

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	
  echo "Ran this command: "${SCRIPTS_DIR}"/mircat.sh" ${DATA_DIR}"/lib"${LIB}"_filt"*"_noncons.fa" ${DIR}
  ${SCRIPTS_DIR}"/mircat.sh" ${DATA_DIR}"/lib"${LIB}"_filt"*"_noncons.fa" ${DIR}
  echo "Finished runing LIB${LIB}"
done

END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)

echo "Mircat took ${DIFF}secs to process all lib" 

ok_log=${log_file/.log/:OK.log}
echo $(basename $ok_log)
mv $log_file $ok_log

exit 0
