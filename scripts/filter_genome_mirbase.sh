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

set -e

err_report() {
   >&2 echo "Error -  on line $1 caused a code $2 exit - $3"
   echo "Error -  on line $1 caused a code $2 exit - $3"
}
trap 'err_report $LINENO $? $(basename $0)' ERR

FILE=$1
SOURCE=$2
xserv=$3
IGNORE_FILTER=$4

# Loading cfg vars
CFG_PATMAN=${SOURCE}"/config/patman_genome.cfg"
CFG=${SOURCE}"/config/wbench_mirprof.cfg"
. ${SOURCE}"/config/wbench_mirprof.cfg"
. ${SOURCE}"/config/software_dirs.cfg"
. ${SOURCE}"/config/workdirs.cfg"
. ${SOURCE}"/config/term-colors.cfg"
. $CFG_PATMAN


err_report() {
   >&2 echo -e "${red}Error${NC} -  on line $1 caused a code $2 exit"
   echo -e "${red}Error${NC} -  on line $1 caused a code $2 exit"
}
trap 'err_report $LINENO $?' ERR

if [[ $HEADLESS == "TRUE" ]]; then
  xserv=${SOURCE}"/./xvfb-run-safe"
fi

#Rename workdir var because of re-config
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
FILTER_GENOME=${WORKDIR}/data/"filter_genome/"
mkdir -p ${FILTER_GENOME}


# create output file
OUT_FILT_GENOME=${FILTER_GENOME}${IN_ROOT}"_"${GENOME_ROOT}".fa"
OUT_CONS=${WORKDIR}/data/${IN_ROOT}"_"${GENOME_ROOT}"_mirbase_cons.fa"
OUT_NONCONS=${WORKDIR}/data/${IN_ROOT}"_"${GENOME_ROOT}"_mirbase_noncons.fa"
OUT_REPORT=${FILTER_GENOME}${IN_ROOT}"_${GENOME_ROOT}_REPORT.csv"




MPF_DIR=${WORKDIR}"/data/mirprof/"
mkdir -p ${MPF_DIR}
MPF_FILE=${MPF_DIR}${IN_ROOT}"_"${GENOME_ROOT}"_mirbase"
MPF_FILE_UNIQ=${MPF_DIR}${IN_ROOT}"_"${GENOME_ROOT}"_mirbase.uniq"

echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} genome filtering"

# align bowtie2 with genome
#bowtie ${GENOME} -f ${FILE} -v 0 --best --al ${OUT_FILT_GENOME} -p ${THREADS} > ${OUT_REPORT}

#Testing if file exists and script has permissions to run it.
testPatman=$(which patman)
echo "testPatman: "$testPatman
checkPatman="TRUE"
command -v patman >/dev/null 2>&1 || { echo "PatMaN required.";checkPatman="FALSE"; }
if [[ -e "$testPatman" && -x "$testPatman" ]]; then

################ADDD IF to skip Patman

	if [[ "${IGNORE_FILTER}" == "TRUE" ]]; then 
		##Copy files to genome filter as if they had been filtered
		echo -e "Genome filtering was ignored\n\n" > ${OUT_REPORT}
		cp ${FILE} ${OUT_FILT_GENOME}
	else  
		#######################################
		 #Patman command
		 run="patman -D ${GENOME} -e ${EDITS} -P ${FILE} -o ${OUT_REPORT} -g ${GAPS} -p ${PREFETCH}"
		if [[ ${SINGLESTRAND} == "TRUE" ]]; then
			printf $(date +"%y/%m/%d-%H:%M:%S")" - Running PatMaN with following command:\n\t${run} -s\n"
			$run -s    
		else
		 	printf $(date +"%y/%m/%d-%H:%M:%S")" - Running PatMaN with following command:\n\t${run}\n"
		 	$run
		fi
		#Patman sorting
		awk -F "\t" '{print $2}' ${OUT_REPORT}| sort | uniq | awk -F "[(]" '{ print ">"$0; newline; print $1}' > ${OUT_FILT_GENOME}
	fi
else
 	##This is not printing out to user?? Fix this       
 	>&2 echo -e "${red}Error${NC} - PatMaN is no properly installed. Either it is not in path or this script doesn't have permission to run it. If you just installed sRNA-workflow with install script please restart terminal to update path. $0:::Line:$LINENO"
 	exit 127
fi

#Even if patman doesn't find anything this it still makes an empty file.
output_size=$(wc -l ${OUT_REPORT} | awk '{print $1}')
if [[ ${output_size} == 0 ]]; then
	printf "###################\n##   ATTENTION ! ##\n###################\n###################\n"
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Filtering ${IN_ROOT} with genome generated no reads\n\tResults for this library ${IN_ROOT} will be irrelevant from this point on.\n"
	>&2 echo ""
	>&2 echo -e "${red}Attention${NC} - Filtering ${IN_ROOT} with genome generated no reads but program will continue." 
	>&2 echo ""
else
	echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} genome filtered"
fi
echo ""
echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} mirbase filtering"

# align mirprof
##Don't filter genome activate below (Used for testing or others)
##cp ${FILE} ${OUT_FILT_GENOME}
mismatches=$(echo "${mismatches}" | tr -d '\r' )
only_keep_best=$(echo "${only_keep_best}" | tr -d '\r' )

function runMiRProf {
	#This function runs miRProf
	#runMiRProf [sRNA file] [output file]

	sRNAfile=$1 #${OUT_FILT_GENOME}
	MPF_FILE_FUNC=$2 #${MPF_FILE}
	match=$3

	#Save miRProf files for backtracking
	MPF_FASTA=${MPF_FILE_FUNC/_mirbase/_mirbase_srnas.fa}
	MPF_CSV=${MPF_FILE_FUNC/_mirbase/_mirbase_profile.csv}


	run="${xserv} ${JAVA_DIR}/java -jar ${WBENCH_DIR}/Workbench.jar -tool mirprof -srna_file_list ${sRNAfile} -mirbase_db ${MIRBASE} -out_file ${MPF_FILE_FUNC} -params ${CFG}"
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Ran miRProf with this command: \n\t${run}\n"
	#Run miRProf
	$run

	
	MPF_FASTA=${MPF_FILE_FUNC/_mirbase/_mirbase_srnas.fa}
	if [[ -e ${MPF_FASTA} ]]; then
		#Create a list of conserved sequences
		grep -v ">" ${MPF_FASTA} > ${MPF_FILE_UNIQ}
		if [[ match -eq 0 ]]; then
			cat ${MPF_FASTA} > ${OUT_CONS}
		else	
			cat ${MPF_FASTA} >> ${OUT_CONS}
		fi	
	else
		#if there are no results create an empty file to avoid errors. The program can still continue
		#Can still be interesting (Should it warn that no cons sRNAs where found?)
		#For example in fungi there are still few or none sRNA documented.
		touch ${MPF_FILE_UNIQ}
		touch ${OUT_CONS}
	fi

	#Create a file with the sequences that didn't align with miRProf
	OUT_NONCONS_TMP=${OUT_NONCONS/.fa/.tmp}
	grep -wvf ${MPF_FILE_UNIQ} ${sRNAfile} > ${OUT_NONCONS_TMP}
	mv ${OUT_NONCONS_TMP} ${OUT_NONCONS}

	if [[ -e ${MPF_FASTA} ]]; then
		#If files already exist save them with the appropriate number of mismatches
		mv ${MPF_FILE_UNIQ} ${MPF_FILE_UNIQ/_mirbase/_mismatch${match}_mirbase}
		mv ${MPF_FASTA} ${MPF_FASTA/_mirbase_/_mismatch${match}_mirbase_}
		mv ${MPF_CSV} ${MPF_CSV/_mirbase_/_mismatch${match}_mirbase_}
	fi	

}

function combineMir {
	# Function to aggregate miRNAs that were identified more than once due to mismatches
	#
	MPF_CONS=$1

	#needed to parse the headers, spaces all split of strings into diff vars.
        sed -ri "s:>all combined:>all_combined:g" ${MPF_CONS}
        #list of sequences that appear more then once in the list of conserved miR
        duplicateSeqs=$(grep -v ">" ${MPF_CONS} | sort | uniq -c | sort | awk '{if($1 > 1){print $2}}' | tr -s "\r\n" " " )
        for seq in $duplicateSeqs; do
                #Removal of the sequences that repeat
		headers_del=$(grep -wB1 "${seq}" ${MPF_CONS} | sed /--/d | sed /$seq/d)
		headers_add=$(grep -wB1 "${seq}" ${MPF_CONS} | sed /--/d | sed /$seq/d | awk -F "mir" '{print $2}')
		echo $headers_del
		for header in $headers_del; do
			sed -i /^$header$/d ${MPF_CONS}
		done
		sed -i /^$seq$/d ${MPF_CONS} 
		#Reintroduction of combined header sequences
		printf ">all combined-mir"$(echo ${headers_add} | sed -r "s:_Abundance\([0-9]+\) :|:g")"\n${seq}\n" >> ${MPF_CONS}
		printf ">all combined-mir"$(echo ${headers_add} | sed -r "s:_Abundance\([0-9]+\) :|:g")"\n${seq}\n"
	done
        sed -ri "s:>all_combined:>all combined:g" ${MPF_CONS}
}


if [[ ${mismatches} -eq 0 ]]; then
	runMiRProf ${OUT_FILT_GENOME} ${MPF_FILE} 0 
else
	if [[ ${only_keep_best} == "true" ]]; then
		#Run with mismatch 0	
		i=0
		sed -ri "s:^(mismatches=)[0-9]+:\1$i:g" ${CFG}
		runMiRProf ${OUT_FILT_GENOME} ${MPF_FILE} ${i} 	

		max=0
		if [[ ${mismatches} -gt 3 ]]; then
			printf $(date +"%y/%m/%d-%H:%M:%S")" - Max mismatches is 3. Mismatches have been set to 3. \n"
			max=3	
		else
			max=${mismatches}
		fi	

		for (( i=1; i<=${max}; i++ ));do

			#Change the mismatch in config file
			sed -ri "s:^(mismatches=)[0-9]+:\1$i:g" ${CFG}
			
			runMiRProf ${OUT_NONCONS} ${MPF_FILE} ${i}
			#now deal with multiple families.
			#1)- miR156_x|157_x_abundance(xx)
			# Merged header for the same sequence
			#
			# Build a by family merger in something other then R. Bash or Python if simpler
			#2)- Only miR156_x|157_x_abundance(xx) but for that I would have to parse the hole thing to merge all that are of a single family
		done
		combineMir ${OUT_CONS}
	else
		runMiRProf ${OUT_FILT_GENOME} ${MPF_FILE} ${mismatches}
	fi	
fi	

echo $(date +"%y/%m/%d-%H:%M:%S")" - ${IN_ROOT} mirbase filtered"

exit 0
