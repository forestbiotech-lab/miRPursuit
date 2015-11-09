#!/bin/sh

# filter_genome_bt_mirbase.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.

# call:
# filter_genome.sh [file] [genome] [Threads] [workdir] [Mirbase]

# rename input
FILE=$1
GENOME=$2
THREADS=$3
WORKDIR=$4
MIRBASE=$5

# define input directory and get input filename(s)
IN_FILE=$(basename ${FILE})
IN_ROOT=${IN_FILE%.*}

GENOME_BASENAME=$(basename ${GENOME})
echo "Using ${GENOME_BASENAME} as the reference genome"

# create patman dir and file
FILTER_GENOME=${WORKDIR}data/"FILTER-Genome/"
mkdir -p ${FILTER_GENOME}


# create output file
OUT_FILT_GENOME=${FILTER_GENOME}${IN_ROOT}"_"${GENOME_BASENAME}".fa"
OUT_CONS=${WORKDIR}data/${IN_ROOT}"_"${GENOME_BASENAME}"_mirbase_cons.fa"
OUT_NONCONS=${WORKDIR}data/${IN_ROOT}"_"${GENOME_BASENAME}"_mirbase_noncons.fa"
OUT_REPORT=${FILTER_GENOME}${IN_ROOT}"_BOWTIE1_${GENOME_BASENAME}_REPORT.csv"




PMN_DIR=${WORKDIR}"data/patman_mb/"
mkdir -p ${PMN_DIR}
PMN_FILE=${PMN_DIR}${IN_ROOT}"_"${GENOME_BASENAME}"_mirbase.csv"
PMN_FILE_TEMP=${PMN_DIR}${IN_ROOT}"_"${GENOME_BASENAME}"_mirbase.uniq"

echo ${IN_ROOT}" genome filtering"

# align bowtie2 with genome
#bowtie ${GENOME} -f ${FILE} -v 0 --best --al ${OUT_FILT_GENOME} -p ${THREADS} > ${OUT_REPORT}
patman -D ${GENOME} -e 0 -P ${FILE} -o ${OUT_REPORT} 
#Patman sorting
awk -F "\t" '{print $2}' ${OUT_REPORT}| sort | uniq | awk -F "[(]" '{ print ">"$0; newline; print $1}' > ${OUT_FILT_GENOME}
#awk -F '\t' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print ">"$0; newline; print $1}' > ${OUT_FILT}

echo ${IN_ROOT}" genome filtered"

echo ${IN_ROOT}" mirbase filtering"

# align patman mirbase
patman -D ${MIRBASE} -e 0 -P ${OUT_FILT_GENOME} -o ${PMN_FILE}
# filter mirbase results and get unique read sequences
awk -F '[\t(]' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print $1}' > ${PMN_FILE_TEMP}

awk '{print $1}' ${PMN_FILE_TEMP} | xargs -n 1 -I pattern grep -w -m1 pattern ${PMN_FILE} | awk -F "[\t()]" '{split($1,a,"-"); match(a[2],"[0-9]+",arr); print "all-combined-"arr[0]"-Abundance("$3")"$2}' | sort | awk -F "[-)]" '{split($3,a,"miR"); if(("c[a[1]]" -eq "0")); then; d=((c[a[1]]++));fi; if (("c[a[1]]" -gt "0")); then; d=((c[a[1]]));fi; print ">"$5"-"$1"-"$2"-miR"a[1]"_"d"_"$4")";newline;print $5;}' > ${OUT_CONS}

#Get sequences that didn't align with mirBase
grep -wvf ${PMN_FILE_TEMP} ${OUT_FILT_GENOME} > ${OUT_NONCONS}

echo ${IN_ROOT}" mirbase filtered"

exit 0
