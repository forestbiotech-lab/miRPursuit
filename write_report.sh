#!/usr/bin/env bash
#
# Copyright Bruno Costa @ iBET 16/02/2017
#
# Write_report.sh
# Writes a multi-part MD report.
#
# call as [first_] [lib_last] [type]

# Types are {"header","fastq","fasta","filtering","genome","end"}

LIB_FIRST=$1
LIB_LAST=$2
TYPE=$3

#  Fastq
#    - Fastqc (For now just this one)
#      Per base sequence quality
#      *Per sequence GC content
#      *Adapter Content
#       
#  Trimming
#    - Detailed Log (Table?)
#  Fasta
#    - Size profiles
#      One graph per lib. 
#      Possible pair-wise comparison depending on lib number. (I think two at most)
#  Filtering
#    - Detailed report of filtering (Grab that log and build table)
#  Genome
#    - (How low details not sure has spot)
#  End
#    - Stats per lib (for each )
#    - Counts per lib. (Issues with matrix size. Needs to be sized)


#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

mkdir -p ${workdir}"count/images"
log_file=$workdir"log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:write_report:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file}) 
exec 2>&1 >> ${log_file}

SCRIPT_DIR=$DIR"/scripts"
OUTPUT_FILE=${workdir}count/miRPursuit_REPORT-Run${PPID}.tex

graphicspath=$(echo ${workdir}count/images/ | sed -r "s:_:\_:g")

if [[ "${TYPE}" == "header" ]]; then
	printf "\\\documentclass{book}
\\\title{miRPursuit - REPORT}
\\\author{miRPursuit - Forest-BiotechLab}
\\\usepackage[utf8]{inputenc}
\\\usepackage{graphicx}
\\\graphicspath{ {${graphicspath}} }
\\\begin{document}
\\\maketitle
Hello world
\\\pagebreak
\\\tableofcontents
\\\pagebreak\n" > $OUTPUT_FILE

    GENOME=$(echo ${GENOME} | sed -r "s:_:\_:g")
    GENOME_BASENAME=$(basename $GENOME)
    GENOME_DIR=${GENOME%.*}
	printf "\t\\\chapter{Introduction}\n\\\section{General Introduction}\nThis report was automatically generated by miRPursuit.\nThe genome used was: ${GENOME_BASENAME}\nLocated in: ${GENOME_DIR}\nUsing miRBase version: \n" >> ${OUTPUT_FILE}
fi

if [[ "${TYPE}" == "fasta" ]]; then
	printf "\\\chapter{Characterization of sRNA libraries}\\\section{sRNA Profile}
This section depicts the sRNA profiles of the various libraries using barplots.\n" >> $OUTPUT_FILE


	#Choses run mode based on input arguments
	cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Copying all fasta files to workdir\n"
	for i in $cycle
	do
	  LIB_NOW=$i
	  LIB=$(printf "%02d\n"  $LIB_NOW)  
	  $SCRIPT_DIR/size_fasta.py --input ${workdir}data/fasta/Lib${LIB}.fa --output ${workdir}count/Lib${LIB}-profile.tsv
	  $SCRIPT_DIR/graph_sizedistr.R ${workdir}count/Lib${LIB}-profile.tsv ${workdir}count/images/
	  #convert image Add image
	printf "
	\\\begin{figure}[h]
	\\\centering
	\\\includegraphics[width=8cm, height=8cm]{Barplot-Lib${LIB}-size-distr}
	\\\caption{Lib${LIB} barplot of sequence length distribution}
	\\\label{fig:profile${LIB}}
	\\\end{figure}\n" >> ${OUTPUT_FILE}



	done

	##Write to tex

fi

#This might not be the right section for this
if [[ "${TYPE}" == "stats" ]]; then
			printf "\chapter{Basic Statistics}\n" >> ${OUTPUT_FILE}

	COUNT=${workdir}count
    
    libs=$(( $LIB_LAST - $LIB_FIRST + 1 ))
    cycles=$(( $libs / 6 + 1 ))
    
	columnStructure="| c |"
	declare -a allCols=(c c c c c c)
	declare -a allLibs=($(eval echo Lib{$LIB_FIRST..$LIB_LAST}))
	for c in {2..3}; do
	    declare -a fastq=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Fastq-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a fasta=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Fasta-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a filter=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Filter-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a genome=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Genome-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a cons=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Cons-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a novel=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/Novel-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	    declare -a tasi=($(awk -v c=$c '{if(NR>1){print $c}}' ${COUNT}/TASI-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))

		cycle=$(eval echo {1..${cycles}})
		for i in $cycle ;do
			columns=$(( $libs - ( $i - 1 ) * 6  ))
			if [[ "${columns}" -gt "0" ]];then
				#if columns = 0; don't print; if < 6 that is the number of columns
				#if bigger use 6 and continue
				if [[ "${columns}" -gt "6" ]];then
					columns=6	
				fi

	            arrStart=$(( ( ( $i - 1 ) * 6 ) ))
	            arrStop=$(( ( ( $i - 1 ) * 6 ) + ${columns} ))

	    		cellStructure=${columnStructure}${allCols[@]:0:${columns}}"|"
	    		tHeader="Step & "$(echo ${allLibs[@]:$arrStart:${columns}} | tr -t " " "&")
	    		fastqLine="Fastq & "$(echo ${fastq[@]:$arrStart:${columns}} | tr -t " " "&")
	    		fastaLine="Fasta & "$(echo ${fasta[@]:$arrStart:${columns}} | tr -t " " "&")
	    		filterLine="Filter & "$(echo ${filter[@]:$arrStart:${columns}} | tr -t " " "&")
	    		genomeLine="Genome & "$(echo ${genome[@]:$arrStart:${columns}} | tr -t " " "&")
	    		consLine="Conserved & "$(echo ${cons[@]:$arrStart:${columns}} | tr -t " " "&")
	    		novelLine="Novel & "$(echo ${novel[@]:$arrStart:${columns}} | tr -t " " "&")
	    		tasiLine="TaSi & "$(echo ${tasi[@]:$arrStart:${columns}} | tr -t " " "&")
	    		if [[ "$c"  == "2" ]];then
	    			captionText="Total reads counts throughout the various steps"
	    			newSection="\\\section{Total read counts}\nThis sections shows the total read count for each step\n\n"
	    		else
	    			captionText="Number of distinct reads throughout the various steps"
	    			newSection="\\\section{Distinct reads counts}\nThis section depicts the number of distinct reads throughout the various steps.\n\n"
				
				printf "${newSection}\\\begin{center}
\\\begin{table}[h]
\\\begin{tabular}{$cellStructure}
\\\hline
${tHeader} \\\\\\
\\\hline
${fastqLine} \\\\\\
${fastaLine} \\\\\\
${filterLine} \\\\\\
${genomeLine} \\\\\\
${consLine} \\\\\\
${novelLine} \\\\\\
${tasiLine} \\\\\\
\\\hline
\\\end{tabular}
\\\caption{${captionText}}
\\\label{table:${i}}
\\\end{table}
\\\end{center}\n\n" >> ${OUTPUT_FILE}

			fi

		done
	done	
fi

if [[ "${TYPE}" == "end" ]]; then

	printf "\\\end{document}\n" >> ${OUTPUT_FILE}

fi