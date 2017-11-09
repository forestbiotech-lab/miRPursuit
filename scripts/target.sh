#!/bin/bash

# target.sh
# 
#
# Created by Bruno Costa on 02/07/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# call target.sh [lib_first] [lib_lab] [source]

LIB_FIRST=$1
LIB_LAST=$2
SOURCE=$3

echo "running"

# read softwares dir
. "${SOURCE}/config/software_dirs.cfg"
# PAREsnip config file
CONFIG="${SOURCE}/config/wbench_paresnip_loose.cfg"
# Env vars
. "${SOURCE}/config/workdirs.cfg"

#for i in {${LIB_FIRST}..${LIB_LAST}}
#Library number
cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
for i in $cycle
do
  LIB_N=$(printf "%02d\n" $i)


  #Create tempfile to temporarly save concatenated input
  tmpfile=$(mktemp -t pairsnip.XXXXXX)
  #Rises error if more than one file (due to different genomes)
  #concatenate. No filtering is being done because they come from different files that  have been split in previous steps
  cat ${workdir}/data/lib${LIB_N}_filt-${FILTER_SUF}_*_cons.fa > $tmpfile
  cat ${workdir}/data/mircat/lib${LIB_N}_filt-${FILTER_SUF}_*_noncons_miRNA_filtered.fa  >> $tmpfile
  ###########################################################

  # create output dir for fasta if not existant
  RESULTS_DIR="${workdir}/data/target"
  mkdir -p ${RESULTS_DIR}
  DEG_NAME=$(basename $DEGRADOME)
  OUT_FILE=${RESULTS_DIR}"/lib${LIB_N}_${DEG_NAME}-targets.txt"

  #OUT_TXT=${OUT_DIR}${IN_ROOT}"_target-"$2".txt"
  #OUT_CSV=${OUT_DIR}${IN_ROOT}"_target-"$2".csv"


  #################
  # ! ATTENTION ! #
  #               #
  # Not prepared  #
  # to use genome #
  #################              

  ##
  cat ${workdir}/count/all_seq.fa  > $tmpfile

  # run target #add -verbose for verbose mode.....
  runPAREsnip="${JAVA_DIR}/java -Xmx${MEMORY} -jar ${WBENCH_DIR}/Workbench.jar -tool paresnip -f -srna_file ${tmpfile} -deg_file ${DEGRADOME} -tran_file ${TRANSCRIPTOME} -out_file ${OUT_FILE} -params ${CONFIG}"
  echo "Ran this command: " $runPAREsnip
  $runPAREsnip

  config="${DEGRADOME}  "
  awk -F "\n" -v pre="${config}" 'BEGIN{RS="-----"}{if(NR==1){print pre$1}else{print pre$2}}' ${OUT_FILE}  > ${OUT_FILE/targets.txt/targets-excell.tsv}
  # move produced resulting files into place
  #mv ${RESULTS_DIR}results.txt ${OUT_TXT}
  #mv ${RESULTS_DIR}results.csv ${OUT_CSV}

  #remove results directory 
  #rm -rf ${RESULTS_DIR}


  #clean up
  rm $tmpfile
done
