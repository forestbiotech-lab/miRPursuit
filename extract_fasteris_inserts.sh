#!/usr/bin/env bash

# extract_fasteris_inserts.sh
# 
#
# Created by Andreas Bohn on 25/03/2014.
# Modified by Bruno Costa on 21/05/2105
# Copyright 2015 ITQB / UNL. All rights reserved.

# Call: extract_fasteris_inserts.sh [LIB_FIRST] [LIB_LAST]
set -e


#Name inputs
LIB_FIRST=$1
LIB_LAST=$2


#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

#Setting up log dir
mkdir -p $workdir"/log/"
log_file="${workdir}/log/"$(date +"%y%m%d:%H%M%S")":PPID$PPID:fastq_to_fasta:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo "alignment finished in "${DIFF}" secs"


echo "Workdir is: "$workdir"\nInserts dir is: "$INSERTS_DIR"\nfastq_xtract.sh ran in s\nlib_cat.sh ran in s\n" > $log_file

#Create count dir
mkdir -p ${workdir}/count/
cFq=${workdir}/count/$(date +"%y%m%d:%H%M%S")"-cFq-lib"${LIB_FIRST}"-"${LIB_LAST}".tsv"
cFq_n=0

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do

  #Create name for read count report
  report_file=${workdir}/count/$(date +"%y%m%d:%H%M%S")"-count-fastq-reads_lib"$LIB_NOW".tsv"
  ((cFq_n++))
  cFq_ln[$cFq_n]=$(echo $report_file)
  echo ${cFq_ln[1]}" fist line of array"

  NPROC=$(($NPROC+1))       
	${SCRIPT_DIR}fastq_xtract.sh $LIB_NOW $INSERTS_DIR $workdir $report_file &
  if [ "$NPROC" -ge "$THREADS" ]; then
    wait
    NPROC=0
  fi

done
wait

echo "Extracted all libraries"

#Concatenate all reports
cHeader="lib_n "$(head -1 ${cFq_ln[1]}) 
echo $cHeader > $cFq

for i in ${cFq_ln[@]}
do
 lib_num=$(echo $i | awk -F "[_.]" '{print $((NF-1))}')      
 num_lines=$(wc -l $i | awk '{print $1}' )
 if [ "$num_lines" == "2" ]; then
   ln="${lib_num} "$(tail -1 $i) 
   echo $ln >> $cFq
 else
   tail -$((num_lines-1)) $i  | awk -v pre=${lib_num} '{print pre" "$0}' >> $cFq
 fi
done

END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo " fastq_xtract.sh ran in ${DIFF} seconds" >> $log_file

START_TIME=$(date +%s.%N)

for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do

  NPROC=$(($NPROC+1))       
	${SCRIPT_DIR}lib_cat.sh $LIB_NOW fq $workdir &
  if [ "$NPROC" -ge "$THREADS" ]; then
    wait
    NPROC=0
  fi
done
wait

 
END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo " lib_cat.sh ran in ${DIFF} seconds" >> $log_file

               
START_TIME=$(date +%s.%N) 
             
for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
  NPROC=$(($NPROC+1))       
	${SCRIPT_DIR}fq_to_fa_exe.sh $workdir $LIB_NOW &
  if [ "$NPROC" -ge "$THREADS" ]; then
    wait
    NPROC=0
  fi
done
wait
END_TIME=$(date +%s.%N)
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo " fq_to_fa_exe.sh ran in ${DIFF} seconds" >> $log_file


#Count fasta seqs
cFa=${workdir}/count/$(date +"%y%m%d:%H%M%S")"-cFa-lib"${LIB_FIRST}"-"${LIB_LAST}".tsv"
echo "lib total distinct" > $cFa   
for ((LIB_NOW=${LIB_FIRST}; LIB_NOW<=${LIB_LAST}; LIB_NOW++))
do
        
  LIB_NOW_NUM=$(printf "%02d\n" $LIB_NOW)      
  FA_FILE=${workdir}/data/fasta/lib${LIB_NOW_NUM}.fa
  FA_COLL=${wokdir}data/fasta/lib${LIB_NOW_NUM}.faC
  fastx_collapser -i $FA_FILE  -o $FA_COLL 
  echo "Count:"$(grep -c ">" $FA_COLL)
  echo "lib"${LIB_NOW_NUM}" "$(grep -c  ">" $FA_FILE)" "$(grep -c ">" $FA_COLL) >> $cFa
  rm FA_COLL
done




ok_log=${log_file/.log/:OK.log}

echo $(basename $ok_log)

duration=$(date -u -d @${SECONDS} +"%T")

printf "Ran in ${duration}\nRan in ${SECONDS}secs\n"
mv $log_file $ok_log

exit 0
