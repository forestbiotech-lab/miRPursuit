#!/bin/sh

# pipe_filter_genome_bt_mirbase.sh
# 
#
# Created by Andreas Bohn on 31/10/2014.
# Modified by Bruno Costa on 25/05/2015
# Copyright 2015 ITQB / UNL. All rights reserved.

# Call: pipe_filter_genome_bt_mirbase.sh  [LIB_FIRST] [LIB_LAST] [Threads] [GENOME] [Filter Suffix]

LIB_FIRST=$1
LIB_LAST=$2
MAXPROC=$3
GENOME=$4
FILT_SUF=$5
echo "Runnning with ${MAXPROC} threads"
#Get dir of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#GET workpaths variables
. $DIR"/config/workdirs.cfg"

# define log file
log_file=${workdir}"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":filter_genome_&_mirbase:"$1":"$2)".log"
echo ${log_file}
exec 2>&1 > ${log_file}
SCRIPT_DIR=${DIR}"/scripts/"
DATA_DIR=${workdir}"data/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	LIB=$(printf "%02d\n" ${LIB_NOW})
	${SCRIPT_DIR}filter_genome_bt_mirbase.sh ${DATA_DIR}"filter_overview/lib"$LIB"_filt-"${FILT_SUF}".fa" ${GENOME} ${MAXPROC} ${workdir} ${MIRBASE}

  echo "Call this:" ${SCRIPT_DIR}filter_genome_bt_mirbase.sh ${DATA_DIR}"filter_overview/lib"$LIB"_filt-"${FILT_SUF}".fa" ${GENOME} ${MAXPROC} ${workdir} ${MIRBASE}

done
wait

#Count reads
HEADER="lib\stotal\sdistinct"
REPORT_OUTPUT=${workdir}"count/"$(date +"%y%m%d:%H%M%S")"-cGenome-lib"${LIB_FIRST}"-"${LIB_LAST}".tsv"
COUNTER=${SCRIPT_DIR}"count_reads.sh"
#genome
GENOME_BASENAME=$(basename ${GENOME})
CF_CNAME=${DATA_DIR}"FILTER-Genome/lib00_filt-"${FILT_SUF}"_"${GENOME_BASENAME}
cFaGenome=${CF_CNAME}".fa"
${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaGenome} ${REPORT_OUTPUT} ${HEADER} 
echo "CounterGenome:"${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaGenome} ${REPORT_OUTPUT} ${HEADER} 
#mirbase
cFaMirCONS=${CF_CNAME/FILTER-Genome\//}"_mirbase_cons.fa"
${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaMirCONS} ${REPORT_OUTPUT/-cGenome-/MirCons} ${HEADER} 

cFaMirNONCONS=${CF_CNAME/FILTER-Genome\//}"_mirbase_noncons.fa"
${COUNTER} ${LIB_FIRST} ${LIB_LAST} ${cFaMirNONCONS} ${REPORT_OUTPUT/-cGenome-/MirNoncons} ${HEADER} 


ok_log=${log_file/.log/:OK.log}
echo $(basename $ok_log)
mv $log_file $ok_log

