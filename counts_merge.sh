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


#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $DIR/"config/workdirs.cfg"
SCRIPTS_DIR=$DIR"/scripts"


mkdir -p ${workdir}/count
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

#clean up
rm $tasiNovel $tasiSeq

exit 0
