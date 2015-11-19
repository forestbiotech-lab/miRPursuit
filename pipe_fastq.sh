#!/usr/bin/env bash

# pipe_fastq.sh
# 
#
# Created by Bruno Costa on 18/11/2105
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# Copies fastq files in $INSERTS_DIR to workdir/data/fastq
# and converts files to fasta.
# Single file can be called by name in $LCSCIENCE_LIB IF only one argument is given
#
# Call: pipe_fastq.sh [LIB_FIRST] [LIB_LAST] [TEMPLATE]
# Call: pipe_fastq.sh [LIB_FIRST]

#Name inputs
LIB_FIRST=$1
LIB_LAST=$2
TEMPLATE=$3

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"


#Setting up log dir
mkdir -p $workdir"log/"
mkdir -p $workdir"data/fastq"
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":pipe_fastq:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"


START_TIME=$(date +%s.%N)

#Chosses run mode based on input arguments
if [[ -z $2 || -z $3 ]]; then
  #Only one argument was given
   CONVERT_LIB=$LCSCIENCE_LIB  #From config file?
   LIB=$LIB_FIRST   
   cp $CONVERT_LIB ${workdir}data/fastq/lib${LIB}.fq &
   ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB}
else
  #Running various threads      
  NPROC=0
  cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
  for i in $cycle
  do 
    LIB_NOW=$i
    LIB=$(printf "%02d\n"  $LIB_NOW)
    CONVERT_LIB=$(ls ${INSERTS_DIR}/*${TEMPLATE}${LIB}*.fq)
    NPROC=$(($NPROC+1))
    cp $CONVERT_LIB ${workdir}data/fastq/lib${LIB}.fq &
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0

  for i in $cycle
  do 
    #Running multiple threads of fq_to_fa_exe.sh
    NPROC=$(($NPROC+1))
    LIB_NOW=$i
    ${SCRIPT_DIR}fq_to_fa_exe.sh ${workdir} ${LIB_NOW} &
    if [ "$NPROC" -ge "$THREADS" ]; then 
      wait
      NPROC=0
    fi

  done
  wait
  NPROC=0

#  for i in $cycle
#  do 
#    #Paralell threading trim-lcschience.sh
#    NPROC=$(($NPROC+1))
#    LIB_NOW=$i
#    ${SCRIPT_DIR}trim-lcscience.sh ${DIR} ${LIB_NOW} & 
#    if [ "$NPROC" -ge "$THREADS" ]; then 
#      wait
#      NPROC=0
#    fi
#
#  done
#  wait

fi

END_TIME=$(date +%s.%N) 
DIFF=$(echo "$END_TIME - $START_TIME" | bc)
echo "alignment finished in "${DIFF}" secs"

echo "Extracted all libraries"

ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log

exit 0
