#!/usr/bin/env bash

#Created by Bruno Costa
#
#Copyright ITQB 2015
#
#

#noncons
for i in {1..18} {25..43}
do        
 awk -F "\n" 'BEGIN{RS=">"}{print $1}' lib${i}*.fai >> noncons.seqs
done

sort noncons.seqs | uniq > noncons.uniq

#overlap 
cat noncons-no-star.uniq tasi-no-star.uniq | awk '{match($0,"[ATCG]*"); if(RLENGTH>2){print $0}}' | sort | uniq -c | awk '{if($1==1){print $2}}' | wc -l

#Remove redundancy
grep -wf miRNA_star.uniq miRNA_star | sort -k2 -t, | awk -F "," 'BEGIN{line="";location=""}{if(location==$2 && NR>1){line=$0;location=$2}else{location=$2;line=$0;print line}}' > miRNAstar_noRedundancy.csv

#TASI

awk '{match($1,"[ATGC]*[(][0-9]*[.][0-9][)]");if(RLENGTH>2){print $1}}' lib*_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_noncons_tasi_srnas.txt > tasi.seqs

cat noncons.uniq ../tasi/tasi.uniq | awk '{match($0,"[ATCG]*"); if(RLENGTH>2){print $0}}' | sort | uniq -c | awk '{if($1>1){print $2}}'

#Get all data tasi
awk '{match($0,".*,.*,.*,.*,.*,.*");if(RLENGTH>=5){line=$0}else{match($0,"[ATCG]*[(][0-9]*[.][0-9]*[)]");if(RLENGTH>2){print $1","line}} }' ~/sRNAall/data/tasi/lib01_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_noncons_tasi_srnas.txt

