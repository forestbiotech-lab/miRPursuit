#!/usr/bin/env bash

# pipe_filter_genome_mirbase.sh
# 
#
# Created by Andreas Bohn on 31/10/2014.
# Modified by Bruno Costa on 25/05/2015
# Copyright 2015 ITQB / UNL. All rights reserved.

# Call: pipe_filter_genome_mirbase.sh  [LIB_FIRST] [LIB_LAST]
set -e

LIB_FIRST=$1
LIB_LAST=$2

#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#GET workpaths variables
. $DIR"/config/workdirs.cfg"

MAXPROC=$THREADS
echo "Runnning with ${MAXPROC} threads"

# define log file
log_file=${workdir}"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":filter_genome_&_mirbase:"$1":"$2)".log"
echo ${log_file}
exec >&1 > ${log_file}
SCRIPT_DIR=${DIR}"/scripts/"
DATA_DIR=${workdir}"data/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	${SCRIPT_DIR}filter_genome_mirbase.sh ${DATA_DIR}"filter_overview/lib"$LIB"_filt-"${FILTER_SUF}".fa" ${DIR}

  echo "Call this:" ${SCRIPT_DIR}filter_genome_mirbase.sh ${DATA_DIR}"filter_overview/lib"$LIB"_filt-"${FILTER_SUF}".fa" ${DIR}

done
wait

##Deprecated code? Redundant code report calculates this.
#Count reads
#       COUNT_DIR=${workdir}count
#       mkdir -p ${COUNT_DIR}
#       HEADER="lib\stotal\sdistinct"
#       REPORT_OUTPUT="${COUNT_DIR}/"$(date +"%y%m%d:%H%M%S")"-cGenome-lib"${LIB_FIRST}"-"${LIB_LAST}".tsv"
#       COUNTER=${SCRIPT_DIR}"count_reads.sh"
#       #genome
#       GENOME_BASENAME=$(basename ${GENOME})
#       GENOME_ROOT=${GENOME_BASENAME%.*}
#       CF_CNAME=${DATA_DIR}"FILTER-Genome/lib00_filt-"${FILTER_SUF}"_"${GENOME_ROOT}
#       cFaGenome=${CF_CNAME}".fa"
#       ${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaGenome} ${REPORT_OUTPUT} ${HEADER} 
#       echo "CounterGenome:"${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaGenome} ${REPORT_OUTPUT} ${HEADER} 
#       #mirbase
#       cFaMirCONS=${CF_CNAME/FILTER-Genome\//}"_mirbase_cons.fa"
#       ${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaMirCONS} ${REPORT_OUTPUT/-cGenome-/MirCons} ${HEADER} 
#
#       cFaMirNONCONS=${CF_CNAME/FILTER-Genome\//}"_mirbase_noncons.fa"
#       ${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaMirNONCONS} ${REPORT_OUTPUT/-cGenome-/MirNoncons} ${HEADER} 


ok_log=${log_file/.log/:OK.log}
echo $(basename $ok_log)
mv $log_file $ok_log

exit 0
