#!/usr/bin/env bash

# sRNAworkFlow.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes the complete pipline
# Call: sRNAworkFlow.sh [inserts_dir] [LIB_FIRST] [LIB_LAST] [STEP]

set -e

while [[ $# > 0 ]]
do
  key="$1"

case $key in
  -f|--lib-first)
  LIB_FIRST="$2"
  shift # past argument
  ;;
  -l|--lib-last)
  LIB_LAST="$2"
  shift # past argument
  ;;
  -s|--step)
  step="$2"
  shift # past argument
  ;;
  --fastq)
  fastq="$2"
  shift #past argument
  ;;
  --fasta)
  fasta="$2"
  shift #past argument
  ;;
  --lc)
  LC="$2"
  shift # past argument
  ;;
  -h|--help)
  echo " 
  -f|--lib-first
  -l|--lib-last
  -h|--help
  ---------------------
  Optional args
  ---------------------
  -s|--step Step is an optional argument used to jump steps to start the analysis from a different point  
      Step 1: Wbench Filter
      Step 2: Filter Genome & mirbase
      Step 3: Tasi
      Step 4: Mircat
      Step 5: PAREsnip    
  --lc Set the program to begin in lcmode instead of fs mode. The preceading substring from the lib num (Pattern) Template + Lib num, but identify only one file in the inserts_dir    
  --fasta Set the program to start using fasta files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fa, Lib_2.fa, .. --> argument should be Lib_
  --fastq Set the program to start using fastq files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fq, Lib_2.fq, .. --> argument should be Lib_ , if no .fq file is present but instead a .fastq.gz file will additionally be extracted automatically.  
  "
  exit 0
esac
shift # past argument or value
done

if [[ -z $LIB_FIRST || -z $LIB_LAST ]]; then
  echo "Missing mandatory parameters"
  echo "use -h|--help for list of commands"
  exit 0
fi
##Should check if libraries exit


if [[ ! -z "$step" ]]; then
  if [[ "$step" -gt 5 ]]; then
     echo "Terminating - That step doen't exist please specify a lower step"         
     exit 0
  fi
fi


#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#Get config settings
. $DIR/"config/workdirs.cfg"


echo "Running pipeline with the following arguments:"
echo "FIRST Library     = ${LIB_FIRST}"
echo "Last Library      = ${LIB_LAST}"
echo "Number of threads = ${THREADS}"
#Test numer of cores is equal or lower the avalible

#Test Filter exists
echo "Filter suffix     = ${FILTER_SUF}"
if [[ -e "${GENOME}" ]]; then        
  echo "Genome          = "${GENOME}
else
  echo "Error - The given genome file doesn't exist please check the file exists. Correct the config file"
  exit 127
fi

if [[ -e "${GENOME_MIRCAT}" ]]; then        
  echo "Genome mircat = "${GENOME_MIRCAT}
else
  echo "Error - The given genome file for mircat doesn't exit please check the file exists. Correct the config file."
fi
#nonempty string bigger than 0 (Can't remember purpose of this!)
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi




mkdir -p $workdir"log/"
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":run_full_pipline:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPTS_DIR=$DIR"/scripts"

#Test if the var step exists
if [[ -z "$step" ]]; then 
  step=0
fi

if [[ ! -z "$LC" ]]; then
  echo "Running in LC mode."
  ${DIR}/extract_lcscience_inserts.sh $LIB_FIRST $LIB_LAST $LC
  step=1
fi
if [[ ! -z "$fastq" ]]; then
  echo "Running in fastq mode."
  ${DIR}/pipe_fastq.sh $LIB_FIRST $LIB_LAST $fastq
  step=1
fi
if [[ ! -z "$fasta" ]]; then
  echo "Running in fasta mode."
  ${DIR}/pipe_fasta.sh $LIB_FIRST $LIB_LAST $fasta
  step=1
fi





if [[ "$step" -eq 0 ]]; then        
  #Concatenate and convert to fasta
  echo "Step 0 - Concatenating lib and converting to fasta..."
  ${DIR}/extract_fasteris_inserts.sh $LIB_FIRST $LIB_LAST
  step=1
fi 
if [[ "$step" -eq 1 ]]; then
  #Filter size, t/rRNA, abundance.
  echo "Step 1 - Filtering lib workbench Filter..."
  ${DIR}/pipe_filter_wbench.sh $LIB_FIRST $LIB_LAST $FILTER_SUF
  step=2
fi
if [[ "$step" -eq 2 ]]; then 
  #Filter genome and mirbase
  echo "Step 2 - Filtering against genome and mirbase..."
  ${DIR}/pipe_filter_genome_mirbase.sh $LIB_FIRST $LIB_LAST
  step=3
fi
if [[ "$step" -eq 3 ]]; then 
  #tasi
  echo "Step 3 - Running tasi, searching for tasi reads..."
  ${DIR}/pipe_tasi.sh $LIB_FIRST $LIB_LAST 
  step=4
fi
if [[ "$step" -eq 4 ]]; then 
  #mircat
  echo " Step 4 - Running mircat..."
  ${DIR}/pipe_mircat.sh $LIB_FIRST $LIB_LAST
  step=5
fi  
if [[ "$step" -eq 5 ]]; then
  mkdir -p ${workdir}count
  novel=${workdir}count/all_seq_counts_novel.tsv
  novelNonCons=${workdir}count/all_seq_counts_nonCons.tsv
  tasi=${workdir}count/all_seq_counts_tasi.tsv
  novelTasi=${workdir}count/all_seq_counts_novelTasi.tsv
  cons=${workdir}count/all_seq_counts_cons.tsv
  consSeq=${workdir}count/all_seq_cons.seq
  star=${workdir}count/all_seq_star.seq
  reunion=${workdir}count/all_seq.tsv
  tasiSeq=`mktemp /tmp/tasiSeq.XXXXXX`
  tasiNovel=`mktemp /tmp/tasiNovel.XXXXXX`
  #Get count matrix save to counts
  $SCRIPTS_DIR/count_abundance.sh "${workdir}data/*_cons.fa" "cons" $THREADS > $cons 
  $SCRIPTS_DIR/count_abundance.sh "${workdir}data/mircat/*noncons_miRNA_filtered.fa" "novel" $THREADS > $novel 
  $SCRIPTS_DIR/count_abundance.sh "${workdir}data/tasi/lib*-tasi.fa" "tasi" $THREADS > $tasi


  #$SCRIPTS_DIR/count_abundance.sh "${workdir}data/*_cons.fa ${workdir}data/mircat/*noncons_miRNA_filtered.fa" "none" $THREADS > ${workdir}count/all_seq_counts.tsv
  
  #This has a script why the snippet instead directly here?

  ##Get the list of seqs with star 
  cat ${workdir}data/mircat/*output_filtered.csv | awk -F ',' '{if($14!="NO"){if($7!="Sequence"){print $7}}}' | sort | uniq > $star

  ###Merging classifications
  awk '{if(NR>1){print $1}}' $tasi > $tasiSeq
  #Merge tasi with novel
  grep -wf $tasiSeq $novel | awk '{print $1}' | xargs -n 1 -I pattern sed -ir "s:pattern\tnovel\t:pattern\tnovel-tasi\t:g" $novel
  ##!!!!Losing tasi if cons
  awk '{if(NR>1){print $1}}' $cons > $consSeq
  grep -wvf $consSeq $novel > $novelNonCons
  grep "tasi" $novelNonCons | awk '{print $1}' > $tasiNovel
  #Create new file for all conserved
  cp $cons $novelTasi
  #Add tasi that aren't novel
  grep -v 'lib' $tasi | grep -wvf $tasiNovel >> $novelTasi
  #Add novel and novel tasi
  grep -v "lib" $novelNonCons >> $novelTasi
  #Add header to new file with all classifications
  head -1 $novelTasi > $reunion
  #Find seq that have star and add to new file
  grep -wf $star $novelTasi | awk '{printf $1"\t"$2" star";for(i=3;i<=NF;i++){printf "\t"$i};printf "\n"}' >> $reunion
  #Add the sequences that aren't star
  grep -v "lib" $novelTasi | grep -vwf $star >> $reunion

  #reports
  $SCRIPTS_DIR/report.sh $LIB_FIRST $LIB_LAST ${DIR}

  #clean up
  rm $tasiNovel $tasiSeq



fi

  

ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log
echo "Workdir is: "$workdir"\nInserts dir is: "$INSERTS_DIR"\nfastq_xtract.sh ran in s\nlib_cat.sh ran in s\n" > $ok_log

exit 0
