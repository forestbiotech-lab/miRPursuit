#!/bin/sh

# sRNA_workFlow.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes the complete pipland
# Call: sRNA_workFlow.sh [inserts_dir] [LIB_FIRST] [LIB_LAST] [THREADS] [FILTER SUFFIX] [Genome]


while [[ $# > 0 ]]
do
  key="$1"

case $key in
  -i|--inserts)
  INSERTS_DIR="$2"
  shift # past argument
  ;;
  -f|--lib-first)
  LIB_FIRST="$2"
  shift # past argument
  ;;
  -l|--lib-last)
  LIB_LAST="$2"
  shift # past argument
  ;;
  -t|--threads)
  THREADS="$2"
  shift # past argument
  ;;
  -s|--filter-suffix)
  FILTER_SUF="$2"
  shift # past argument
  ;;
  -g|--genome)
  GENOME="$2"
  shift # past argument
  ;;
  -m|--genome-mircat)
  GENOME_MIRCAT="$2"
  shift # past argument
  ;;
  -h|--help)
  echo " 
  -i|--inserts
  -f|--lib-first
  -l|--lib-last
  -t|--threads
  -s|--filter-suffix
  -g|--genome
  -m|--genome-mircat
  -h|--help
  "
  exit 0
esac
shift # past argument or value
done
if [[ -z $INSERTS_DIR || -z $LIB_FIRST || -z $LIB_LAST || -z $THREADS || -z $FILTER_SUF || -z $GENOME ]]; then
  echo "Missing mandatory parameters"
  echo "use -h|--help for list of commands"

  exit 0
fi
echo "Running pipeline with the following arguments:"
echo "Inserts directory  = ${INSERTS_DIR}"
echo "FIRST Library     = ${LIB_FIRST}"
echo "Last Library    = ${LIB_LAST}"
echo "Number of threads = ${THREADS}"
echo "Filter suffix = ${FILTER_SUF}"
echo "Genome = "${GENOME}
echo "Genome mircat = "${GENOME_MIRCAT}
#nonempty string bigger than 0
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi


#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Get config settings
. $DIR/"config/workdirs.cfg"

mkdir -p $workdir"log/"
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":run_full_pipline:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"

#Concatenate and convert to fasta
${DIR}/extract_fasteris_inserts.sh $INSERTS_DIR $LIB_FIRST $LIB_LAST
#Filter size, t/rRNA, abundance.
${DIR}/pipe_filter_wbench.sh $LIB_FIRST $LIB_LAST $FILTER_SUF
#Filter genome and mirbase
${DIR}/pipe_filter_genome_bt_mirbase.sh $LIB_FIRST $LIB_LAST $THREADS $GENOME $FILTER_SUF
#mircat
${DIR}/pipe_mircat.sh $LIB_FIRST $LIB_LAST $GENOME_MIRCAT


ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log
echo "Workdir is: "$workdir"\nInserts dir is: "$INSERTS_DIR"\nfastq_xtract.sh ran in s\nlib_cat.sh ran in s\n" > $ok_log

exit 0
