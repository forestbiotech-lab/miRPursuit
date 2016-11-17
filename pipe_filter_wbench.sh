#!/usr/bin/env bash

# pipe_filter_wbench.sh
# 
#
# Created by Andreas Bohn on 31/10/2014.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Modified by Bruno Costa on 22/05/2015
# Call: pipe_filter_wbench.sh [LIB_FIRST] [LIB_LAST]
set -e

LIB_FIRST=$1
LIB_LAST=$2

#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get workpath variables
. $DIR/config/workdirs.cfg


# define log file
log_file="${workdir}log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:filters:${1}-${2}.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec >&1 > ${log_file}
printf "\nRan with these vars:\n###################\n#wbench_filter.cfg#\n###################\n"
cat $DIR/config/wbench_filter_in_use.cfg
printf "\n\n"


SCRIPT_DIR=${DIR}"/scripts/"
FASTA_DIR=${workdir}"data/fasta/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	
	run="${SCRIPT_DIR}filter_wbench.sh ${FASTA_DIR}lib${LIB}.fa ${DIR}"
  	printf $(date +"%y/%m/%d-%H:%M:%S")" - Ran filter helper script with this command: \n\t${run}\n"
	$run

done
#wait for all threads to finish before continuing.
wait
printf $(date +"%y/%m/%d-%H:%M:%S")" - Finished filtering all libs\n"

ok_log=${log_file/.log/:OK.log}

duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nThis script ran in ${duration}\n${SECONDS}sec.\n"
printf "Processed with filter "$WB_FILT"\n"
echo $(basename $ok_log)
mv $log_file $ok_log


exit 0
