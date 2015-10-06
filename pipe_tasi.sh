#!/bin/sh

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
log_file=${workdir}"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":tasi:"$1":"$2)".log"
#echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR=${DIR}"/scripts/"
DATA_DIR=${workdir}"data/"

#Count execution time
START_TIME=$(date +%s.%N)

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})  
  RUN_TASI=$(echo ${SCRIPT_DIR}tasi.sh ${DATA_DIR}"lib"$LIB"_filt-"*"_mirbase_noncons.fa" ${DIR})
  $RUN_TASI
  echo "Ran this command: "
  echo " "$RUN_TASI
done

END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)

ok_log=${log_file/.log/:OK.log}
echo $(basename $ok_log)
mv $log_file $ok_log
echo "Finished in ${DIFF} sec."

exit 0
