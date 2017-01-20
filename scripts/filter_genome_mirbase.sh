#!/usr/bin/env bash

# filter_genome_mirbase.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.

# call:
# filter_genome_mirbase.sh [file] [source]

# rename input

#Important if this fail no point to continue
#Problem continuing if no result is found.
#set -e

FILE=$1
SOURCE=$2
xserv=$3

# Loading cfg vars
CFG_PATMAN=${SOURCE}"/config/patman_genome.cfg"
CFG=${SOURCE}"/config/wbench_mirprof.cfg"
. ${SOURCE}"/config/software_dirs.cfg"
. ${SOURCE}"/config/workdirs.cfg"
. ${SOURCE}"/config/term-colors.cfg"
. $CFG_PATMAN


if [[ $HEADLESS == "TRUE" ]]; then
	xserv=xvfb-run
fi

#Rename workdir var beacause of reconfig
WORKDIR=$workdir

printf "\nRan with these vars:\n####################\n#wbench_mirprof.cfg#\n####################\n"
cat $CFG
printf "\n\n"

# define input directory and get input filename(s)
IN_FILE=$(basename ${FILE})
IN_ROOT=${IN_FILE%.*}

GENOME_BASENAME=$(basename ${GENOME})
GENOME_ROOT=${GENOME_BASENAME%.*}
echo $(date +"%y/%m/%d-%H:%M:%S")" -Using ${GENOME_BASENAME} as the reference genome"

# create patman dir and file
FILTER_GENOME=${WORKDIR}data/"filter_genome/"
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

echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} genome filtering"

# align bowtie2 with genome
#bowtie ${GENOME} -f ${FILE} -v 0 --best --al ${OUT_FILT_GENOME} -p ${THREADS} > ${OUT_REPORT}

#Testing if file exists and script has permissions to run it.
testPatman=$(which patman)
if [[ -e $testPatman && -x $testPatman ]]; then
 #Patman command
 run="patman -D ${GENOME} -e ${EDITS} -P ${FILE} -o ${OUT_REPORT} -g ${GAPS} -p ${PREFETCH}"
 if [[ ${SINGLESTRAND} == "TRUE" ]]; then
	echo $(date +"%y/%m/%d-%H:%M:%S")" - Running patman with following command\n\t${run} -s\n"
	$run -s    
 else
 	echo $(date +"%y/%m/%d-%H:%M:%S")" - Running patman with following command\n\t${run}\n"
 	$run
 fi
else
 ##This is not printing out to user?? Fix this       
 >&2 echo -e "${red}Error${NC} - Patman is no properly installed. Either it is not in path or this script doesn't have permission to run it. If you just installed sRNA-workflow with install script please restart terminal to update path. $0:::Line:$LINENO"
 exit 127
fi
#Even if patman doesn't find anything this it still makes an empty file.

#Patman sorting
awk -F "\t" '{print $2}' ${OUT_REPORT}| sort | uniq | awk -F "[(]" '{ print ">"$0; newline; print $1}' > ${OUT_FILT_GENOME}
#awk -F '\t' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print ">"$0; newline; print $1}' > ${OUT_FILT}

output_size=$(wc -l ${OUT_REPORT} | awk '{print $1}')
if [[ ${output_size} == 0 ]]; then
	printf "###################\n##   ATTENTION ! ##\n###################\n###################\n"
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Filtering ${IN_ROOT} with genome generated no reads\n\tResults for this library ${IN_ROOT} will be irrelevant from this point on.\n"
	>&2 echo ""
	>&2 echo -e "${red}Attention${NC} - Filtering ${IN_ROOT} with genome generated no reads but program will continue" 
	>&2 echo ""
else
	echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} genome filtered"
fi
echo ""
echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} mirbase filtering"

# align mirprof
##Don't filter genome activate below (Used for testing or others)
##cp ${FILE} ${OUT_FILT_GENOME}

##patman -D ${MIRBASE} -e 0 -P ${OUT_FILT_GENOME} -o ${PMN_FILE}
run="${xserv} ${JAVA_DIR}/java -jar ${WBENCH_DIR}/Workbench.jar -tool mirprof -srna_file_list ${OUT_FILT_GENOME} -mirbase_db ${MIRBASE} -out_file ${MPF_FILE} -params ${CFG}"
printf $(date +"%y/%m/%d-%H:%M:%S")" - Ran mirprof with this command: \n\t${run}\n"
#Run mirprof
$run
# filter mirbase results and get unique read sequences
##awk -F '[\t(]' '{print $2}' ${PMN_FILE} | sort | uniq | awk -F '(' '{print $1}' > ${PMN_FILE_TEMP}

##awk '{print $1}' ${PMN_FILE_TEMP} | xargs -n 1 -I pattern grep -w -m1 pattern ${PMN_FILE} | awk -F "[\t()]" '{split($1,a,"-"); match(a[2],"[0-9]+",arr); print "all-combined-"arr[0]"-Abundance("$3")"$2}' | sort | awk -F "[-)]" '{split($3,a,"miR"); if(("c[a[1]]" -eq "0")); then; d=((c[a[1]]++));fi; if (("c[a[1]]" -gt "0")); then; d=((c[a[1]]));fi; print ">"$5"-"$1"-"$2"-miR"a[1]"_"d"_"$4")";newline;print $5;}' > ${OUT_CONS}

#Get sequences that didn't align with mirBase
MPF_FASTA=${MPF_FILE/_mirbase/_mirbase_srnas.fa}
if [[ -e ${MPF_FASTA} ]]; then
	#If empty this give an error.
	grep -v ">" ${MPF_FASTA} > ${MPF_FILE_TEMP}
	cp ${MPF_FASTA} ${OUT_CONS}
else
	#if there are no results create an empty file to avoid errors. The program can still continue
	#Can still be interessing (Should it warn that no cons sRNAs where found?)
	#For example in fugae there are still few or none sRNA documented.
	touch ${MPF_FILE_TEMP}
	touch ${OUT_CONS}
fi

grep -wvf ${MPF_FILE_TEMP} ${OUT_FILT_GENOME} > ${OUT_NONCONS}

echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} mirbase filtered"

exit 0
