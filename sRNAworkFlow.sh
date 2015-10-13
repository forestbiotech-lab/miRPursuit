#!/bin/sh

# sRNA_workFlow.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes the complete pipland
# Call: sRNA_workFlow.sh [args]


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
  -t|--template)
  TEMPLATE="$2"
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
  -t|--template Set the program to begin in lcmode instead of fs mode. The preceading substring from the lib num (Pattern) Template + Lib num mas identify only one file in the inserts_dir    
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
echo "Last Library    = ${LIB_LAST}"
echo "Number of threads = ${THREADS}"
echo "Filter suffix = ${FILTER_SUF}"
echo "Genome = "${GENOME}
echo "Genome mircat = "${GENOME_MIRCAT}
#nonempty string bigger than 0 (Can't remember purpose of this!)
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi




mkdir -p $workdir"log/"
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":run_full_pipline:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"

#Test if the var step exists
if [[ -z "$step" ]]; then 
  step=0
fi
#Runs in LCScience Mode
if [[ ! -z "$TEMPLATE" ]]; then
  echo "Running in LC mode."
  ${DIR}/extract_lcscience_inserts.sh $LIB_FIRST $LIB_LAST $TEMPLATE
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
  ${DIR}/pipe_filter_genome_bt_mirbase.sh $LIB_FIRST $LIB_LAST $THREADS $GENOME $FILTER_SUF
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
  #Get count matrix save to counts
  $SCRIPT_DIR/count_abundance.sh "${wokdir}data/*_cons.fa ${workdir}data/mircat/*noncons_miRNA_filtered.fa" $THREADS > ${workdir}count/all_seq_counts.tsv
fi 


ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log
echo "Workdir is: "$workdir"\nInserts dir is: "$INSERTS_DIR"\nfastq_xtract.sh ran in s\nlib_cat.sh ran in s\n" > $ok_log

exit 0
