#!/bin/sh

# count_reads.sh
# 
#
# Created by Bruno Costa on 06/06/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# call count_reads.sh [lib_first] [lib_last] [model_file] [report(out file)] [header]
#
# define input directory and get input filename(s)
LIB_FIRST=$1
LIB_LAST=$2
MODEL_FILE=$3
REPORT=$4
HEADER=$5

#Write header
echo ${HEADER} |  sed -e "s:\\\s: :g" > $REPORT

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do 
  LIB_NUM=$(printf "%02d\n" ${LIB_NOW})
  FA_FILE=${MODEL_FILE/lib[0-9][0-9]/lib${LIB_NUM}}
  #count total reads
  total_reads=$(awk -F "[()]"  'BEGIN{RS=">"; a=0} {a+=$2} END{print a}'  $FA_FILE)
  echo "lib"${LIB_NOW}" "${total_reads}" "$(grep -c ">" $FA_FILE) >> $REPORT 
done



