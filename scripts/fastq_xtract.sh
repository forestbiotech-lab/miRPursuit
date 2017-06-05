#!/usr/bin/env bash

# fastq_xtract.sh
# 
#
# Created by Andreas on 04/06/2014.
# Copyright 2014 ITQB / UNL. All rights reserved.

# extract / untar original insert tar files
# call fastq_xtract.sh [lib_no] [Inserts_dir] [workdir] [report_file]

set -e

#rename input vars
lib_n=$1
insertsdir=$2
workdir=$3
report_file=$4

err_report(){
 echo " Error on line $1 caused a code $2 exit"
 echo " $3"
}
trap 'err_report $LINENO $?' ERR

printf "workdir is: $workdir/n"
printf "Inserts dir is: $insertsdir/n"

# define input directory and get input filename(s)
tar_files=${insertsdir}"/"*"GZT-"${lib_n}"_"*".tar.gz"

# define and create output directory if necessary
out_dir=${workdir}"data/fastq"
echo "out dir is: "$out_dir
mkdir -p $out_dir 

# loop if more than 1 one file per library 
counter=0
# zero-pad library number
lib=$(printf "%02d\n" ${lib_n})
for tar_now in ${tar_files}
do
  echo "extracting "$tar_now
  # compose output file name

  echo "Tar now:"$tar_now
  # get lane number
  base_tar=$(basename $tar_now)
  lane=$(echo $base_tar | awk -F "_" '{print substr($((NF-2)),4)}')

  # compose name
  out=${out_dir}"/lib"${lib}"_ln"${lane}".fq"
  echo "the lane is: "$lane
  echo "out is: "$out
  # extract tar_dir/tar_now
  echo "out_dir is: "$out_dir
  tar -zxf ${tar_now} -C ${out_dir}
 
  #Change names to order names
  for i in {1..9}
  do 
    oi=$(printf "%02d\n" ${i})
    olane=$(printf "%03d\n" ${lane})
    old_file=$(ls ${out_dir}"/"*"L"${olane}"_GZT-"${lib_n}*".InsertSize"${i}".fastq") 
    new_file=${old_file/InsertSize$i/InsertSize$oi}
    mv $old_file $new_file
  done

  #count NoAdaptor sequences
  gunzip ${out_dir}/*"_GZT-"${lib_n}*"NoAdapt.fastq.gz"
  count_noAdapt=$(wc -l ${out_dir}/*"_GZT-"${lib_n}*"NoAdapt.fastq" | awk '{print (($1 / 4))}' ) 

  header=$(wc -l ${out_dir}"/"*"_GZT-"${lib_n}*".InsertSize"*".fastq" | awk -F "." '{print$((NF-1))}')
  if [ "$counter" -lt "1" ]; then
    echo "Lane NoAdapt "$header >> ${report_file} 
  fi
  ((counter++))  
  count_size=$(wc -l ${out_dir}"/"*"_GZT-"${lib_n}*".InsertSize"*".fastq" | awk '{print (($((NF-1))/4)) }' )
   
  echo "Ln"${lane}" "${count_noAdapt}" "${count_size} >> $report_file

  cat ${out_dir}"/"*"_L"*"_GZT-"${lib_n}"_"*".InsertSize"*".fastq"  > $out
  
  #clean up
  rm ${out_dir}"/"*"_L"*"_GZT-"${lib_n}"_"*".fastq"

  echo "lib"${lib}"_ln"${lane}".fq done"
done
