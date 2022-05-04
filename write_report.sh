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

mkdir -p ${workdir}"/count/images/.temp"
log_file=$workdir"/log/"$(date +"%y|%m|%d-%H:%M:%S")":PPID${PPID}:write_report:$1-$2.log"
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file}) 
exec 2>&1 >> ${log_file}

SCRIPT_DIR=$DIR"/scripts"
OUTPUT_FILE=${workdir}/count/miRPursuit_REPORT-Run${PPID}.tex

graphicspath=$(echo ${workdir}/count/images/ | sed -r "s:_:\_:g")


if [[ "${TYPE}" == "complete" ]]; then
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST header
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST fasta
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST filter
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST stats
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST conserved
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST file_overview
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST logs
	bash $DIR/write_report.sh $LIB_FIRST $LIB_LAST end
fi

if [[ "${TYPE}" == "header" ]]; then
	libs=$(( $LIB_LAST - $LIB_FIRST + 1 ))
	printf "\\\documentclass{article}
\\\usepackage[utf8]{inputenc}
\\\usepackage{graphicx}
\\\usepackage{longtable}
\\\usepackage{caption}
\\\usepackage{multirow}
%%https://pt.sharelatex.com/learn/Page_size_and_margins
%%210mmx297mm A4 euro
\\\usepackage[a4paper,left=15mm, total={170mm, 257mm}]{geometry}
\\\usepackage[section]{placeins}
\\\captionsetup[h!]{justification=justified,singlelinecheck=false,indention=0cm,format=hang}
\\\captionsetup[longtable]{justification=justified,singlelinecheck=false,indention=0cm}
\\\graphicspath{ {${graphicspath}} }
\\\begin{document}
\\\title{miRPursuit - REPORT}
\\\author{miRPursuit - Forest-BiotechLab}
\\\maketitle
\\\begin{center}
Analysis of ${libs} sRNA libraries 
\\\end{center}
\\\pagebreak
\\\tableofcontents
\\\pagebreak\n" > $OUTPUT_FILE
	mirbaseREADME=${MIRBASE/mature.fa/README}
	if [[ -e "${mirbaseREADME}" ]]; then
		miRBaseVersion=$(head -1 $mirbaseREADME | sed -r "s:^(.*Release )([0-9]+)$:\2:g" ) 
	fi

    GENOME=$(echo ${GENOME} | sed -r "s:_:\\\_:g")
    GENOME_BASENAME=$(basename $GENOME)
    GENOME_DIR=${GENOME%/*} #Not working
	printf "\\\section{Introduction}
\\\subsection{General Introduction}
This report was automatically generated by miRPursuit.\\\\\\
The genome used was: ${GENOME_BASENAME}\\\\\\
Located in: ${GENOME_DIR}\\\\\\
Using miRBase version: ${miRBaseVersion} \\\\\\
Using the adaptor sequence: ${ADAPTOR}\\\\\\
" >> ${OUTPUT_FILE}
fi

if [[ "${TYPE}" == "fasta" ]]; then
	printf "\\\section{Characterization of sRNA libraries}
\\\subsection{sRNA Profile Fasta}
\\\begin{flushleft}
This section depicts the sRNA profiles of the various libraries using barplots. These bar plots were generated from fasta data, and thus before most filtering steps. Possible filtering steps that may have been applied are quality cutoff of fastq reads (phred 33 for illumina) and adaptor trimming. The decrease in the number of reads can be viewed in Table \\\ref{table}, the basic statisctic section. 
\\\end{flushleft}\n" >> $OUTPUT_FILE


	#Choses run mode based on input arguments
	cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Copying all fasta files to workdir\n"
	for i in $cycle
	do
	  LIB_NOW=$i
	  LIB=$(printf "%02d\n"  $LIB_NOW)  
	  $SCRIPT_DIR/size_fasta.py --input ${workdir}/data/fasta/Lib${LIB}.fa --output ${workdir}/count/Lib${LIB}-profile.tsv
	  $SCRIPT_DIR/graph_sizedistr.R ${workdir}/count/Lib${LIB}-profile.tsv ${workdir}/count/images/
	  #convert image Add image
	printf "
\\\begin{figure}[h!]
\\\centering
\\\includegraphics[width=8cm, height=8cm]{Barplot-Lib${LIB}-size-distr}
\\\caption{Lib${LIB} barplot of sequence length distribution}
\\\label{fig:profile${LIB}}
\\\end{figure}\n" >> ${OUTPUT_FILE}



	done
	printf "\\\newpage\\\newpage\n\n" >> ${OUTPUT_FILE}		

	##Write to tex

fi


##I think this should have the figures side by side for barplots with two series. But this is a quick fix to start viewing filtered barplots.
if [[ "${TYPE}" == "filter" ]]; then
	printf "\\\section{Characterization of sRNA libraries}
\\\subsection{sRNA Profile Filtered}
\\\begin{flushleft}
This section depicts the sRNA profiles of the various libraries using barplots. These bar plots were generated from filtered data, just before the genome filtering step. The decrease in the number of reads can be viewed in Table \\\ref{table}, the basic statisctic section. 
\\\end{flushleft}\n" >> $OUTPUT_FILE


	#Choses run mode based on input arguments
	cycle=$(eval echo {${LIB_FIRST}..${LIB_LAST}})
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Copying all filtered files to workdir\n"
	for i in $cycle
	do
	  LIB_NOW=$i
	  LIB=$(printf "%02d\n"  $LIB_NOW)  
	  $SCRIPT_DIR/size_fasta.py --input ${workdir}/data/filter_overview/Lib${LIB}_filt-${FILTER_SUF}.fa --output ${workdir}/count/Lib${LIB}-filtered-profile.tsv
	  $SCRIPT_DIR/graph_sizedistr.R ${workdir}/count/Lib${LIB}-filtered-profile.tsv ${workdir}/count/images/
      
      #Remove all underscores  
      for i in ${workdir}/count/images/Barplot-Lib*_filt.${FILTER_SUF}-size-distr.png;
      do
        #This is to ensure that only the file name is changed.  
        y=$(echo $i | awk -F "count/images/" '{print $2}')    
        #Replace all underscores
        z=${y//_/-}  
        mv $i ${workdir}/count/images/$z  
        #Replace first period
        mv ${workdir}/count/images/$z ${workdir}/count/images/${z/./-}  
      done
	  #convert image Add image
	printf "
\\\begin{figure}[h!]
\\\centering
\\\includegraphics[width=8cm, height=8cm]{Barplot-Lib${LIB}-filt-${FILTER_SUF//_/-}-size-distr}
\\\caption{Lib${LIB} barplot of sequence length distribution}
\\\label{fig:profile${LIB}}
\\\end{figure}\n" >> ${OUTPUT_FILE}



	done
	printf "\\\newpage\\\newpage\n\n" >> ${OUTPUT_FILE}		

	##Write to tex

fi



#This might not be the right section for this
if [[ "${TYPE}" == "stats" ]]; then
			printf "\section{Basic Statistics}\n" >> ${OUTPUT_FILE}

	COUNT=${workdir}/count
    
    libs=$(( $LIB_LAST - $LIB_FIRST + 1 ))
    cycles=$(( $libs / 6 + 1 ))
    
	columnStructure="| r |"
	declare -a allCols=(r r r r r r)
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
    			captionText="Total reads counts throughout the various steps.\label{table}"
    			newSubSection="\\\subsection{Total read counts (isolated)}\nThis sections shows the total read count for each step. This count is based on the individual counts for each library. It might differ for novel miRNAs due to statistical cut-offs.\n\n"
    		else
    			captionText="Number of distinct reads throughout the various steps.\label{table}"
    			newSubSection="\\\subsection{Distinct reads counts}\nThis section depicts the number of distinct reads throughout the various steps.\n\n"
				fi

				if [[ "${i}" -eq "1" ]];then 
					printf "$newSubSection" >> ${OUTPUT_FILE}
				fi

				printf "
					\\\begin{table}[h!]
					\\\centering
					\\\caption{${captionText}}
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
					\\\end{table}\n" >> ${OUTPUT_FILE}

			fi

		done
	done

	

	cycle=$(eval echo {1..${cycles}})
	declare -a novelTotal=($(awk -v c=2 '{if(NR>1){print $c}}' ${COUNT}/Novel-Global-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
	declare -a novelDistinct=($(awk -v c=3 '{if(NR>1){print $c}}' ${COUNT}/Novel-Global-Lib${LIB_FIRST}-${LIB_LAST}.tsv | tr -t "\n" " "))
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

			columnStructure="| r | r |"
			declare -a allCols=(r r r r r r)
			declare -a allLibs=($(eval echo Lib{$LIB_FIRST..$LIB_LAST}))
			cellStructure=${columnStructure}${allCols[@]:0:${columns}}"|"
			tHeader="\\\multicolumn{2}{|c|}{} & "$(echo ${allLibs[@]:$arrStart:${columns}} | tr -t " " "&")
			
		

			captionText="Global read counts"
			distinct_global_counts="\\\multirow{2}{1em}{\\\rotatebox{90}{ novel}} & Distinct & "$(echo ${novelDistinct[@]:$arrStart:${columns}} | tr -t " " "&")
			total_global_counts=" & Total & "$(echo ${novelTotal[@]:$arrStart:${columns}} | tr -t " " "&")

			#Set subsections
			if [[ "${i}" -eq "1" ]];then 
				printf "\\\subsection{Global counts (Novel miRNAs)}\n\\\begin{flushleft}\nThis section contains a table with the counts of the novel miRNAs, identified throughout all the sequenced libraries mentioned in this report.\n This might differ from the individual count, since miRCat might define some novel miRNAs out of bounds of the statistical threshold in some libraries. The expression for these novel miRNAs, is retreived from the previous stage for all the globally predicted novel miRNAs.\\\end{flushleft}\n\n">> ${OUTPUT_FILE}
			fi
			# Make a table with the count of novel miRNAs detected in all libraries.
			printf "
				\\\begin{table}[h!]
				\\\centering
				\\\caption{${captionText}}
				\\\begin{tabular}{$cellStructure} 
%%%%|r|r|r r r r r r|
				\\\hline
				${tHeader} \\\\\\
				\\\hline
				${distinct_global_counts} \\\\\\
				${total_global_counts} \\\\\\
				\\\hline
				\\\end{tabular}
				\\\end{table}\n" >> ${OUTPUT_FILE}	
		fi
	done

	printf "\\\newpage\\\newpage\n\n" >> ${OUTPUT_FILE}
fi



if [[ "${TYPE}" == "conserved" ]]; then
	printf "\\\section{Conserved miRNAs}\n\\\begin{flushleft}\nThis section contains a table with the raw read counts of the conserved reads for each of the libraries. A \".tsv\" file can be found in the workdir/count/ directory. File: all\_seq\_counts\_cons.tsv.\n\\\end{flushleft}\n" >> ${OUTPUT_FILE}
	COUNTS=${workdir}/count
	conservedMat=${COUNTS}/all_seq_counts_cons_merged.tsv
	libs=$(( $LIB_LAST - $LIB_FIRST + 1 ))
    cycles=$(( $libs / 6 + 1 ))
    
	columnStructure="| l |" ## ll
	declare -a allCols=(r r r r r r)
	declare -a allLibs=($(eval echo Lib{$LIB_FIRST..$LIB_LAST}))

	   


	cycle=$(eval echo {1..${cycles}})
	for i in $cycle ;do
		columns=$(( $libs - ( $i - 1 ) * 6  ))
		if [[ "${columns}" -gt "0" ]];then
			#if columns = 0; don't print; if < 6 that is the number of columns
			#if bigger use 6 and continue
			if [[ "${columns}" -gt "6" ]];then
				columns=6	
			fi

            tColumns=$(( ${columns} + 1 )) ##Changes this for double first col (2)
            arrStart=$(( ( ( $i - 1 ) * 6 ) ))
            arrStop=$(( ${arrStart} + ${columns} ))

    		cellStructure=${columnStructure}${allCols[@]:0:${columns}}"|"
    		tHeader="miR & "$(echo ${allLibs[@]:$arrStart:${columns}} | tr -t " " "&")
    		#fastqLine="Fastq & "$(echo ${fastq[@]:$arrStart:${columns}} | tr -t " " "&")
    		
    		##Not finished here. Might be done

    		firstCol=$(( $arrStart + 3 ))
            lastCol=$(( $arrStop + 2 )) ## (3)
    		table=$(awk -F "\t" -v s=$firstCol -v e=${lastCol} '{if(NR>1){printf $1" & "$2" &  ";for (i=s;i<(e-1); i+=1){printf $i" & "}; print $(e-1)" \\\\\\ \\n"}}' ${conservedMat} | sed -r "s:([$%#_]):\\\\\1:g" )
    	
    		captionText="Conserved reads matrix raw values.\label{long}"
    		
			
			printf "\\\begin{longtable}{$cellStructure}
\\\caption{${captionText}} \\\\\\
\\\hline
\\\multicolumn{${tColumns}}{| c |}{Begin of conserved table \\\ref{long}} \\\\\\
\\\hline
${tHeader} \\\\\\
\\\hline
\\\endfirsthead

\\\hline
\\\multicolumn{${tColumns}}{| c |}{Continuation of table \\\ref{long}} \\\\\\
\\\hline
${tHeader} \\\\\\
\\\hline
\\\endhead

\\\hline
\\\endfoot

\\\hline
\\\multicolumn{${tColumns}}{| c |}{End of table \\\ref{long}} \\\\\\
\\\hline
\\\hline
\\\endlastfoot
">> ${OUTPUT_FILE}

			echo -e ${table} >> ${OUTPUT_FILE}
			printf "\\\end{longtable}\n" >> ${OUTPUT_FILE}

		fi

	done
	printf "\\\newpage\n\n" >> ${OUTPUT_FILE}		

fi



if [[ ${TYPE} == "file_overview"  ]]; then
	printf "\\\section{File overview} The following table (Table:\\\ref{tab:FileLocations}) contains a reference to locate all the relevant files for this run. The global matrix can be used to export counts into statistical software. It is generally used to perform differential expression analysis. Novel miRNAs folder lists all the miRNAs that were predicted by miRCat. TaSi miRNAs are listed in TaSi Folder. A fasta with the conserved sequences can be found in the main folder $(printf "${workdir}/data/" | sed -r "s:([$%#_&]):\\\\\1:g"), however the detailed description of how it was determined will be found in the folder in the table below (Table:\\\ref{tab:FileLocations}).  
	\\\begin{table}[h]
	    \\\centering
	    \\\begin{tabular}{| p{0.35\linewidth} | p{0.6\linewidth}|}
	         \\\hline
	         Description & File Location \\\\\\
	         \\\hline
	         Global matrix & $(printf "${workdir}/counts/all\_seq.tsv" | sed -r "s:([$%#_&]):\\\\\1:g") \\\\\\
	         \\\hline
	         Novel sequences &  $(printf "${workdir}/data/mircat" | sed -r "s:([$%#_&]):\\\\\1:g") \\\\\\
	         \\\hline
	         TaSi sequences & $(printf "${workdir}/counts/tasi" | sed -r "s:([$%#_&]):\\\\\1:g")  \\\\\\
	         \\\hline
	         Conserved sequences & $(printf "${workdir}/data/mirprof" | sed -r "s:([$%#_&]):\\\\\1:g") \\\\\\
	         \\\hline         
	    \\\end{tabular}
	    \\\caption{List of file locations}
	    \\\label{tab:FileLocations}
	\\\end{table}" >> ${OUTPUT_FILE}
fi

if [[ "${TYPE}" == "logs" ]]; then
	printf "\\\section{Logs}\n" >> ${OUTPUT_FILE}
	LOGS=${workdir}/log
	#Choose last dir. 
	lastlog=$(ls -d ${LOGS}/*/ | tail -1)
	if [[ -e $(ls "${LOGS}"/*Global*  | tail -1) ]]; then
		printf "\\\subsection{Global log}\n" >> ${OUTPUT_FILE}
		sed -r "s:$:\\\\\\\:g" $(ls "${LOGS}"/*Global*  | tail -1) | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo "${lastlog}"/*pipe_fastq*) ]]; then
		printf "\\\subsection{Pipe Fastq}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*pipe_fastq*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo ${lastlog}/*pipe_fasta*) ]]; then
		printf "\\\subsection{Pipe Fasta}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*pipe_fasta*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo "${lastlog}"/*filters*) ]]; then
		printf "\\\subsection{Filtering}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*filters*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo "${lastlog}"/*genome_*_mirbase*) ]]; then
		printf "\\\subsection{Genome and Mirbase Filtering}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*genome*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo ${lastlog}/*mircat*) ]]; then
		printf "\\\subsection{Mircat}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*mircat*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	if [[ -e $(echo "${lastlog}"/*tasi*) ]]; then
		printf "\\\subsection{TaSi}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*tasi*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	#Extra for another log.
	if [[ -e $(echo "${lastlog}"/*tasi---*) ]]; then
		printf "\\\subsection{TaSi}\n" >> ${OUTPUT_FILE}
		log=$(echo "${lastlog}"/*tasi*)
		sed -r "s:$:\\\\\\\:g" "${log}" | sed -r "s:([$%#_&]):\\\\\1:g" >> ${OUTPUT_FILE}
	fi
	##Are there others?

fi

if [[ "${TYPE}" == "end" ]]; then
	printf "\\\end{document}\n" >> ${OUTPUT_FILE}
fi
