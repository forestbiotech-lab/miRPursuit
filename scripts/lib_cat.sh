#!/bin/sh

# lib_cat.sh
# 
#
# Created by Andreas on 04/06/2014.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Modified by Bruno Costa on 22/05/2015
# concatenate libraries with several files
# call lib_cat.sh [lib_no] [fq/fa] [workdir]

# define input directory and get input filename(s)
ext=$2
workdir=$3
fastq_dir=${workdir}/data/fastq/

lib=$(printf "%02d\n" ${1})
files=$(ls ${fastq_dir}"lib"${lib}"_"*"."$ext | awk -F "/" '{print $NF}')
files_long=$(ls ${fastq_dir}"lib"${lib}"_"*"."$ext )
echo $files

# define and create directory for original lanes if necessary
two_lane_dir="two_lane_libs"
mkdir -p ${fastq_dir}${two_lane_dir}
# create output filename
out="lib"${lib}.$ext
echo ${out}
# count input files
x=( $files )
n_files=$(echo ${#x[@]})
# check number of inputs
if [ "$n_files" = "1" ]; then
  # if 1 file only: rename by deleting lane info
  mv ${fastq_dir}${files} ${fastq_dir}${out}
else
  # if 2 files: concatenate and move originals to $orig_dir

  cat ${fastq_dir}"lib"${lib}_*.$2 > ${fastq_dir}${out}
  mv ${files_long} ${fastq_dir}${two_lane_dir}
  echo mv ${files} ${fastq_dir}${two_lane_dir}
fi
echo "done"
