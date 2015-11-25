#!/usr/bin/env bash

# mircat.sh
# 
#
# Created by Andreas Bohn on 25/03/2014.
# Modified by Bruno Costa on 28/05/2015.
# Copyright 2014-2015 ITQB / UNL. All rights reserved.
#
# call mircat.sh [file] [source]

# read softwares dir


#rename inputs
FILE=$1
SOURCE=$2


# configuration file paths
#GENOME_FILE="./input/"${GENOME}
CFG=${SOURCE}"/config/wbench_mircat.cfg"
echo   ${SOURCE}"/config/software_dirs.cfg"
. ${SOURCE}"/config/software_dirs.cfg"
. ${SOURCE}"/config/workdirs.cfg"

#rename workdir
WORKDIR=$workdir

# define input directory and get input filename(s)
IN_FILE=$(basename $FILE)
IN_DIR=$(dirname $FILE)
IN_ROOT=${IN_FILE%.*}

#tmpfile=$(mktemp -t sedCollapsedMircatInput.XXXXXX)
#tmpfileUn=$(mktemp -t mircatInput.XXXXXX)
#uncollapse to feed to mircat
#sed -r "s:([(])([0-9]*)([)]):-\2:g" $FILE  >$tmpfile
#fastx_uncollapser -i $tmpfile -o $tmpfileUn
#rm $tmpfile



#Check if that is more than one part.
GENOME_BASENAME=$(basename $GENOME_MIRCAT)
GENOME_DIR=$(dirname $GENOME_MIRCAT)


parts=$( echo "$GENOME_BASENAME" | awk -F "part" '{print NF}' )



echo ${IN_ROOT}
# create output file
OUT_FASTA=${WORKDIR}"data/mircat/"${IN_ROOT}"_mircat.fasta"

# create output dir for fasta if not existant
RESULTS_DIR=${WBENCH_DIR}"/output/"
mkdir -p ${RESULTS_DIR}
OUT_DIR=${WORKDIR}"data/mircat/"
mkdir -p ${OUT_DIR}

OUT_HAIRPINS=${OUT_DIR}${IN_ROOT}"_hairpins.txt"
OUT_OUTPUT=${OUT_DIR}${IN_ROOT}"_output.csv"
OUT_STRUCTURES=${OUT_DIR}${IN_ROOT}"_structures.pdf"

if [ "$parts" == "1" ]; then

  # run mircat on filtered file
  runMircat="${JAVA_DIR}/java -Xmx${MEMORY} -jar ${WBENCH_DIR}/Workbench.jar -verbose -tool mircat -srna_file ${FILE} -out ${RESULTS_DIR} -genome ${GENOME_MIRCAT} -params ${CFG}"
  echo "Running mircat with this command: " $runMircat
  $runMircat

  # move produced resulting files into place
  mv ${RESULTS_DIR}miRNA.fa ${OUT_DIR}${IN_ROOT}_miRNA.fa
  mv ${RESULTS_DIR}miRNA_hairpins.txt ${OUT_DIR}${IN_ROOT}_miRNA_hairpins.txt
  mv ${RESULTS_DIR}output.csv ${OUT_DIR}${IN_ROOT}_output.csv

else
 
  GENOME_SUFF=$( echo "$GENOME_BASENAME" | awk -F "part" '{print $1}')
  GENOMES=$(ls ${GENOME_DIR}/${GENOME_SUFF}"part"* )
  #remove old files it they exist because of the append in the for loop. A backup of these file could also be created if necessary.
  rm ${OUT_DIR}${IN_ROOT}_miRNA.fa ${OUT_DIR}${IN_ROOT}_mirRNA_hairpins.txt ${OUT_DIR}${IN_ROOT}_output.csv 
  for i in ${GENOMES}
  do        
    # run mircat on filtered file
    runMircat="${JAVA_DIR}/java -Xmx${MEMORY} -jar ${WBENCH_DIR}/Workbench.jar -verbose -tool mircat -srna_file ${FILE} -out ${RESULTS_DIR} -genome $i -params ${CFG}" 
    echo "Running part: "$i
    echo "Running mircat with this command: " $runMircat
    $runMircat
    # move produced resulting files into place
    cat ${RESULTS_DIR}miRNA.fa >> ${OUT_DIR}${IN_ROOT}_miRNA.fa
    cat ${RESULTS_DIR}miRNA_hairpins.txt >> ${OUT_DIR}${IN_ROOT}_miRNA_hairpins.txt
    cat ${RESULTS_DIR}output.csv >> ${OUT_DIR}${IN_ROOT}_output.csv
  done
fi
OUTPUT_TB=${OUT_DIR}${IN_ROOT}_output.csv
OUTPUT_TBG=${OUT_DIR}${IN_ROOT}_output_grouped.csv
#Rearrange table |Change parts subtracting 1 so its nicer looking
awk 'BEGIN{RS="Chromosome,Start,End,Orientation,Abundance,Sequence,sRNA length,# Genomic Hits,Hairpin Length,Hairpin % G/C content,Minimum Free Energy,Adjusted MFE,miRNA*";FS="\n";print"Part,Chromosome,Start,End,Orientation,Abundance,Sequence,sRNA length,# Genomic Hits,Hairpin Length,Hairpin % G/C content,Minimum Free Energy,Adjusted MFE,miRNA*"}{for(i=2; i<NF; i++ ){if( NR>1 ){print NR-1","$i;}} }' ${OUTPUT_TB} > ${OUTPUT_TBG}
echo "Ran to point 1"

#read mircat config file adding it vars
. ${CFG}
lines=$(($(echo $(wc -l ${OUTPUT_TBG}) | awk '{print $1}')-1))
echo "max genome hits=${max_genome_hits}"
#csv comes sorted by part (col1) so I sort if by seq (col7) to parse it through this algorithum
#get all unique seq and see which have a combined total of more than (16) genomic hits  
tail -${lines} ${OUTPUT_TBG} | awk -F "," '{print $7}' | sort | uniq | xargs -n 1 -I pattern grep pattern ${OUTPUT_TBG} | awk -F "," -v max=${max_genome_hits} 'BEGIN{sum=0;seq="";part=""} { if($7==seq){
   if($1!=part){
    #print "Debug "seq" sum:"sum" $9:"$9" part:"part" $1:"$1
    sum+=$9
    part=$1
    #print "Debug "seq" "sum
    if(sum>max){
      print seq" "sum                                                           
    }
   }
 }else{
  seq=$7 
  sum=$9
  part=$1   
 }
}' | awk '{print $1}' | uniq > ${OUT_DIR}uniq_res.txt
echo "Ran to point 2"
#!Not finished!Now remove all line containing this these seqs from files. 
miRNA_F=${OUT_DIR}${IN_ROOT}_miRNA_filtered.fa
grep -wvf ${OUT_DIR}uniq_res.txt ${OUTPUT_TBG} > ${OUTPUT_TBG/_grouped.csv/_filtered.csv}
grep -wvf ${OUT_DIR}uniq_res.txt ${OUT_DIR}${IN_ROOT}_miRNA.fa > ${miRNA_F}
grep -wvf ${OUT_DIR}uniq_res.txt ${OUT_DIR}${IN_ROOT}_miRNA_hairpins.txt > ${OUT_DIR}${IN_ROOT}_miRNA_hairpins_filtered.txt
tmpFileSED=$(mktemp -t sedTempMircatCor.XXXXXX)
sed -r "s:[.][0-9][)]:):g" ${miRNA_F} > $tmpFileSED
mv $tmpFileSED ${miRNA_F}

echo "Ran to point 3"
#cleanUp
#rm $tmpfileUn

exit 0
