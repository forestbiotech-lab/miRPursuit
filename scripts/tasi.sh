#!/bin/sh
#
# tasi.sh
# 
#
# Created by Andreas Bohn on 25/03/2014.
# Modified by Bruno Costa on 12/06/2015
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# call tasi.sh [file] [source]

#rename inputs
FILE=$1
SOURCE=$2


# read softwares dir and workdirs
. ${SOURCE}/config/software_dirs.cfg
. ${SOURCE}/config/workdirs.cfg

# configuration file paths
CFG="${SOURCE}/config/wbench_tasi.cfg"


# define input directory and get input filename(s)
IN_FILE=$(basename $FILE)
IN_DIR=$(dirname $FILE)
IN_ROOT=${IN_FILE%.*}

#Check if there is more than one part
GENOME_BASENAME=$(basename $TASI_GENOME)
GENOME_DIR=$(dirname $TASI_GENOME)
echo "The genome used was "${GENOME_BASENAME}

## remove conserved sequences from input file
#CONS=${IN_DIR}"/"${IN_ROOT}"_cons.fa"
#grep -v ">" ${CONS} > ${CONS}"_seqs"
#grep -Fwvf ${CONS}"_seqs" $1 > $1"_no_cons"
#rm ${CONS}"_seqs"

## remove putative novel sequences from input file
#PNOV=${IN_DIR}"/"${IN_ROOT}"_putnov.fa"
#grep -v ">" ${PNOV} > ${PNOV}"_seqs"
#grep -Fwvf ${PNOV}"_seqs" $1"_no_cons" > $1"_no_hits"
#rm ${PNOV}"_seqs"

# create output file
OUT_DIR=${workdir}"data/tasi"
mkdir -p $OUT_DIR
OUT_FILE=${OUT_DIR}"/"${IN_ROOT}_tasi

# run filter
RUN_TASI="${JAVA_DIR}/java -jar ${WBENCH_DIR}/Workbench.jar -tool tasi -f -srna_file ${FILE} -genome ${GENOME} -out_file ${OUT_FILE} -params ${CFG}"
$RUN_TASI
echo "Ran tasi with the following command:"
echo " "${RUN_TASI}

#Not sure what to do next | which information is needed.
# create fasta with detected sequences
#grep "(" ${OUT_FILE}"_srnas.txt" | awk -F " " '{print $1}' | sort | uniq | awk -F"(" '{print ">"$0; newline; print $1}' > ${IN_DIR}"/"${IN_ROOT}"_tasi.fa"

## clean up
#rm $1"_no_hits"
#rm $1"_no_cons"

