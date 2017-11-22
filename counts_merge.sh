#!/usr/bin/env bash
  
# counts_merge.sh
#
# Created by Bruno Costa on 01/02/2016
# Copyright 2016 ITQB / UNL. All rights reserved.
# Script to produce and merge all count tables together 
# Call: counts_merge.sh

#if [[ "$#" != 1 ]]; then
#  echo "Error - This script runs with x arguments $# arguments were given"
#  exit 127
#fi

set -e
err_report() {
    >&2 echo "Error -  on line $1 caused a code $2 exit - $3"
    echo "Error -  on line $1 caused a code $2 exit - $3"
}
trap 'err_report $LINENO $? $(basename $0)' ERR





#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/"config/workdirs.cfg"
SCRIPTS_DIR=$DIR"/scripts"


mkdir -p ${workdir}/count
novel=${workdir}/count/all_seq_counts_novel.tsv 			#Novel only
noncons=${workdir}/count/all_seq_counts_nonCons.tsv 		#Make file for first batch of pseudo novel 
novelSeq=${workdir}/count/all_seq_novel.seq 				#
tasi=${workdir}/count/all_seq_counts_tasi.tsv 				#
tasiSeq=${workdir}/count/all_seq_tasi.seq 					#
novelTasi=${workdir}/count/all_seq_counts_novelTasi.tsv 	#
novelTasiSeq=${workdir}/count/all_seq_novelTasi.seq 		#
cons=${workdir}/count/all_seq_counts_cons.tsv 				#
consSeq=${workdir}/count/all_seq_cons.seq 					#
star=${workdir}/count/all_seq_star.seq 						#
reunion=${workdir}/count/all_seq.tsv 						#
novelTmpSeq=`mktemp /tmp/novelSeq.XXXXXX` 					#
novelTmp=`mktemp /tmp/novel.XXXXXX`	 						#
tasiTmpSeq=`mktemp /tmp/tasiSeq.XXXXXX` 					#
tasiTmp=`mktemp /tmp/tasi.XXXXXX` 					#
#Get count matrix save to counts
$SCRIPTS_DIR/count_abundance.sh "${workdir}/data/*_cons.fa" "cons" $THREADS > $cons
$SCRIPTS_DIR/merge_conserved.py -i $cons

for LIB in $(ls ${workdir}/data/mircat/*noncons_miRNA_filtered.fa | sed -r "s:.*Lib([0-9]*)_.*:\1:g")
do
	$SCRIPTS_DIR/identify_conserved.py --cons $cons --fasta ${workdir}/data/mircat/Lib${LIB}_*noncons_miRNA_filtered.fa --csv_mircat ${workdir}/data/mircat/Lib${LIB}_*_noncons_output_filtered.csv
done

###################NOVEL###############################################################
#######Create a list of noncons sequences 
$SCRIPTS_DIR/count_abundance.sh "${workdir}/data/mircat/*noncons_miRNA_filtered.fa" "novel" $THREADS > $noncons
#Filter from noncons which are novel (Have precursor)
for LIB in $(ls ${workdir}/data/mircat/*noncons_miRNA_filtered.fa | sed -r "s:.*Lib([0-9]*)_.*:\1:g")
do
	#Stores all novel sequences to temp file
	grep -A1 ">[ATGC]*_novel" ${workdir}/data/mircat/Lib${LIB}_*noncons_miRNA_filtered_annotated.fa | sed /^\>/d | sort | uniq >> $novelTmpSeq 
done
#Save unique novel sequences
sort $novelTmpSeq | uniq > $novelSeq
#Keep novel seq in noncons list | NO HEADER
grep -wf $novelSeq $noncons > $novelTmp 

####################TASI####################
#Temporary general tasi counts and sequences
#If file fasta file is empty if will add a - line with no sequence for each library
$SCRIPTS_DIR/count_abundance.sh "${workdir}/data/tasi/Lib*-tasi.fa" "tasi" $THREADS > $tasiTmp
awk '{if(NR>1){print $1}}' $tasiTmp > $tasiTmpSeq
	
	#Not sure what none is not in use!
	#$SCRIPTS_DIR/count_abundance.sh "${workdir}/data/*_cons.fa ${workdir}/data/mircat/*noncons_miRNA_filtered.fa" "none" $THREADS > ${workdir}/count/all_seq_counts.tsv

############Conserved#######
#List of conserved sequences
awk '{if(NR>1){print $1}}' $cons > $consSeq

##########################STAR###############################
##Get the list of seqs with star |||| Does this get them all?
cat ${workdir}/data/mircat/*output_filtered.csv | awk -F ',' '{if($14!="NO"){if($7!="Sequence"){print $7}}}' | sort | uniq > $star

##Identify reads that are both tasi and novel only
grep -wf $tasiTmpSeq $novelTmp | awk '{print $1}' | xargs -n 1 -I pattern sed -r "s:pattern\tnovel\t:pattern\tnovel-tasi\t:g" $novelTmp > $novelTasi
awk '{print $1}' $novelTasi > $novelTasiSeq

###Save novel only - No tasi
head -1  $cons > $novel 
grep -vwf $tasiTmpSeq $novelTmp | cat >> $novel
awk '{if(NR>1){print $1}}' $novel > $novelSeq

###Save tasi only - Remove novel and conserved reads
grep -vwf $novelTasiSeq $tasiTmp | grep -vwf $consSeq | cat > $tasi
awk '{if(NR>1){print $1}}' $tasi > $tasiSeq



###Merging classifications
##Start combining reads into one file
## Might be novel and tasi but can't be tasi and conserved. If conserved it's annotation should contemplate the fact that it is a tasiRNA! Unless they aren't in miRBase! A question for later.
#Add conserved reads
cat $cons > $reunion
#Add novel and novelTasi only without header
sed /^\\t\\tLib\.\*/d $novel >> $reunion
cat $novelTasi >> $reunion
#Add tasi only without header
sed /^\\t\\tLib\.\*/d $tasi >> $reunion


	###################NOT adding star sequences because star isn't catching them all ##############
	#	#Find seq that have star and add to new file
	#	grep -wf $star $novelTasi | awk '{printf $1"\t"$2" star";for(i=3;i<=NF;i++){printf "\t"$i};printf "\n"}' >> $reunion
	#	#Add the sequences that aren't star
	#	grep -v "lib" $novelTasi | grep -vwf $star >> $reunion
	################################################################################################
	
#clean up
rm $tasiTmpSeq $tasiTmp $novelTmpSeq $novelTmp
#	
exit 0
