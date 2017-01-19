#!/usr/bin/env bash

# fq_to_fa_exe.sh
# 
#
# Created by Andreas Bohn on 04/06/2014.
# Copyright 2014 ITQB / UNL. All rights reserved.

# call fq_to_fa_exe.sh [work_dir] [lib_no] [file op]

# define input directory and get input filename(s)
set -e

work_dir=${1}
fastq_dir=${work_dir}"data/fastq"
fasta_dir=${work_dir}"data/fasta"
qual_dir=${work_dir}"data/quality"
mkdir -p ${qual_dir}
mkdir -p ${fasta_dir}
lib=$(printf "%02d\n" ${2})

files=$(ls ${fastq_dir}"/Lib"${lib}*".fq")

# loop if more than 1 one file per library
for file_now in $files
do
	# print file treated now
	echo "fastq_to_fasta "$file_now
	# define outputfile
  basename_file_now=$(basename ${file_now})
	out=$(echo $basename_file_now | awk '{gsub("fq","fa"); print}')
	# perform fastqc
	fastq_to_fasta -Q33 -i ${file_now} -o ${fasta_dir}"/"${out}
	#Quality scores
	fastx_quality_stats -Q33 -i ${fastq_dir}"/lib"${lib}".fq" -o ${qual_dir}"/lib"${lib}".stat"
	/usr/local/bin/fastq_quality_boxplot_graph.sh -i ${qual_dir}"/lib"${lib}".stat" -t lib${lib} -p -o ${qual_dir}"/lib"${lib}".pdf"

	echo "done"
done

exit 0
