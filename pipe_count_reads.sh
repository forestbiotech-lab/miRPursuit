#!/usr/bin/env bash

# pipe_fastq_to_fasta.sh
# 
#
# Created by Andreas Bohn on 25/03/2014.
# Copyright 2014 ITQB / UNL. All rights reserved.

# Call: pipe_count_reads.sh [dir] [LIB_FIRST] [LIB_LAST]

LIB_FIRST=$2
LIB_LAST=$3

log_file="log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":count_reads:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR="./scripts/"

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
	${SCRIPT_DIR}count_reads.sh $1 $LIB_NOW
	${SCRIPT_DIR}count_1st_base.sh $1 $LIB_NOW
	${SCRIPT_DIR}count_length.sh $1 $LIB_NOW
	#${SCRIPT_DIR}count_mirprof.sh data/filter_spruce1 spruce1 $LIB_NOW
done

ok_log=$(echo ${log_file} | awk '(gsub(".log",":OK.log"))')