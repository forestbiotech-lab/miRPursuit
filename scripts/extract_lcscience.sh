#!/bin/sh

# extract_lcscience.sh
# 
#
# Created by Bruno Costa on 18/06/2015.
# Copyright 2014 ITQB / UNL. All rights reserved.
#
# extract gzip original raw files
# call extract_lcscience.sh [source] [LIB (output num)] [EXTRACT_LIB]

#rename input vars
SOURCE=$1
LIB=$2
EXTRACT_LIB=$3

#get config vars
. ${SOURCE}/config/workdirs.cfg

# define and create output directory if necessary
out_dir=${workdir}"/data/fastq"
mkdir -p $out_dir 

# loop if more than 1 one file per library 
counter=0
# zero-pad library number
lib=$(printf "%02d\n" ${LIB})

echo "extracting:"$INSERTS_DIR
# compose output file name
out=${out_dir}"/lib"${lib}.fq
echo "out is: "$out
  
# extract tar_dir/tar_now
gunzip -c ${EXTRACT_LIB} > ${out}
 

  #count NoAdaptor sequences
  #count_noAdapt=$(wc -l ${out_dir}/*"_GZT-"${lib_n}*"NoAdapt.fastq" | awk '{print (($1 / 4))}' ) 

  #header=$(wc -l ${out_dir}"/"*"_GZT-"${lib_n}*".InsertSize"*".fastq" | awk -F "." '{print$((NF-1))}')
  #if [ "$counter" -lt "1" ]; then
  #  echo "Lane NoAdapt "$header >> ${report_file} 
  #fi
  #((counter++))  
  #count_size=$(wc -l ${out_dir}"/"*"_GZT-"${lib_n}*".InsertSize"*".fastq" | awk '{print (($((NF-1))/4)) }' )
   
  #echo "Ln"${lane}" "${count_noAdapt}" "${count_size} >> $report_file

  #cat ${out_dir}"/"*"_L"*"_GZT-"${lib_n}"_"*".InsertSize"*".fastq"  > $out
  

  echo "lib"${lib}".fa done"

exit 0
