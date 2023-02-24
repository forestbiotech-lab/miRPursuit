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
. $DIR/config/software_dirs.cfg
. $DIR/"config/term-colors.cfg"

# define log file
log_file="${workdir}/log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:filters:${1}-${2}.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec >&1 > ${log_file}
printf "Ran with these vars:\n###################\n#wbench_filter.cfg#\n###################\n"
cat $DIR/config/wbench_filter_in_use.cfg
printf "\n\n"


function checkRunningLog {
	##TODO maybe restrict to first few RUNS. 
	parent_pid=$1

  iter=0
	checking="true"
	lastLineInLog=""
	while [ "${checking}" == "true" ] | [ "${iter}" -lt "20" ]
	do
		iter=$(( iter+1 ))
		lastLineInLog=$(tail -1 ${log_file})
		if [[ ${lastLineInLog} == "Please tell the software if you are a commerical or academic user by typing com or aca" ]]; then
			#tail -3 ${log_file} > /dev/tty
			
			echo -e "\n\n\n${red}   !!WARNING!!${NC}\nLicense has to be accepted on a differnt run, please run the following command first to confirm the licence for the first run:\n\n\n    ${yellow}||\n    ||\n    \\\/${NC}\n${run}\n    ${yellow}/\\\ \n    ||\n    ||${NC}\n\n Then you can run miRPursuit normally.\n">/dev/tty

			workbench_pid=$(pstree -p $parent_pid | grep "bash.*java" | awk -F '[()]' '{print $4}' )
			kill -9 $workbench_pid
			#my_status=$?
			#echo "kill process status: $status"
			sleep 20
			# TODO still not the most elegant break
			exit 2
			iter="40"  #If all hell fails, this should stop the cycle. 
		else
			finishString=$(tail -3 ${log_file} | head -1 | awk '{print $2}')
			if [[ "${finishString}" == "Postprocessing" ]]; then			
				exit 0
			else	
				sleep 5
			fi
		fi
	done
  exit 0
}


SCRIPT_DIR=${DIR}"/scripts/"
FASTA_DIR=${workdir}"/data/fasta/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	
	run="${SCRIPT_DIR}filter_wbench.sh ${FASTA_DIR}Lib${LIB}.fa ${DIR}"
  	printf $(date +"%y/%m/%d-%H:%M:%S")" - Ran filter helper script with this command: \n\t${run}\n"
	checkRunningLog $$ &
	check_pid=$!
	$run
	wait $check_pid
	

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
