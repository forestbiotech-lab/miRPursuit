#!/usr/bin/env bash

# filter_genome_mirbase.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.

# call:
# filter_genome_mirbase.sh [file] [source]

# rename input
FILE=$1
SOURCE=$2

# Loading cfg vars
. ${SOURCE}"/config/software_dirs.cfg"
. ${SOURCE}"/config/workdirs.cfg"

#Rename workdir var beacause of reconfig
WORKDIR=$workdir


# define input directory and get input filename(s)
IN_FILE=$(basename ${FILE})
IN_ROOT=${IN_FILE%.*}

GENOME_BASENAME=$(basename ${GENOME})
GENOME_ROOT=${GENOME_BASENAME%.*}
echo "Using ${GENOME_BASENAME} as the reference genome"

# create patman dir and file
FILTER_GENOME=${WORKDIR}data/"FILTER-Genome/"
mkdir -p ${FILTER_GENOME}


# create output file
OUT_FILT_GENOME=${FILTER_GENOME}${IN_ROOT}"_"${GENOME_ROOT}".fa"
OUT_CONS=${WORKDIR}data/${IN_ROOT}"_"${GENOME_ROOT}"_mirbase_cons.fa"
OUT_NONCONS=${WORKDIR}data/${IN_ROOT}"_"${GENOME_ROOT}"_mirbase_noncons.fa"
OUT_REPORT=${FILTER_GENOME}${IN_ROOT}"_${GENOME_ROOT}_REPORT.csv"




MPF_DIR=${WORKDIR}"data/mirprof/"
mkdir -p ${MPF_DIR}
MPF_FILE=${MPF_DIR}${IN_ROOT}"_"${GENOME_ROOT}"_mirbase"
MPF_FILE_TEMP=${MPF_DIR}${IN_ROOT}"_"${GENOME_ROOT}"_mirbase.uniq"

echo ${IN_ROOT}" genome filtering"

# align bowtie2 with genome
#bowtie ${GENOME} -f ${FILE} -v 0 --best --al ${OUT_FILT_GENOME} -p ${THREADS} > ${OUT_REPORT}

#Testing if file exists and script has permissions to run it.
testPatman=$(which patman)
if [[ -e $testPatman && -x $testPatman ]]; then
 patman -D ${GENOME} -e 0 -P ${FILE} -o ${OUT_REPORT} 
else
 ##This is not printing out to user?? Fix this       
 echo "Error - Patman is no proparly installed. Either it is not in path or this script doesn't have permission to run it. If you just installed sRNA-workflow with install script please restart terminal to update path. $0:::Line:$LINENO"
 exit 1
fi

#Patman sorting
awk -F "\t" '{print $2}' ${OUT_REPORT}| sort | uniq | awk -F "[(]" '{ print ">"$0; newline; print $1}' > ${OUT_FILT_GENOME}
#awk -F '\t' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print ">"$0; newline; print $1}' > ${OUT_FILT}


echo ${IN_ROOT}" genome filtered"

echo ${IN_ROOT}" mirbase filtering"

# align mirprof
##Don't filter genome activate below (Used for testing or others)
##cp ${FILE} ${OUT_FILT_GENOME}

##patman -D ${MIRBASE} -e 0 -P ${OUT_FILT_GENOME} -o ${PMN_FILE}
${JAVA_DIR}"/java" -jar ${WBENCH_DIR}"/Workbench.jar" -tool mirprof -srna_file_list ${OUT_FILT_GENOME} -genome ${GENOME}  -mirbase_db ${MIRBASE} -out_file ${MPF_FILE}
# filter mirbase results and get unique read sequences
##awk -F '[\t(]' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print $1}' > ${PMN_FILE_TEMP}

##awk '{print $1}' ${PMN_FILE_TEMP} | xargs -n 1 -I pattern grep -w -m1 pattern ${PMN_FILE} | awk -F "[\t()]" '{split($1,a,"-"); match(a[2],"[0-9]+",arr); print "all-combined-"arr[0]"-Abundance("$3")"$2}' | sort | awk -F "[-)]" '{split($3,a,"miR"); if(("c[a[1]]" -eq "0")); then; d=((c[a[1]]++));fi; if (("c[a[1]]" -gt "0")); then; d=((c[a[1]]));fi; print ">"$5"-"$1"-"$2"-miR"a[1]"_"d"_"$4")";newline;print $5;}' > ${OUT_CONS}

#Get sequences that didn't align with mirBase
grep -v ">" ${MPF_FILE/_mirbase/_mirbase_srnas.fa} > ${MPF_FILE_TEMP}
cp ${MPF_FILE/_mirbase/_mirbase_srnas.fa} ${OUT_CONS}
grep -wvf ${MPF_FILE_TEMP} ${OUT_FILT_GENOME} > ${OUT_NONCONS}

echo ${IN_ROOT}" mirbase filtered"

exit 0
