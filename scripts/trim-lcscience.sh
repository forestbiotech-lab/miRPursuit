#!/bin/sh

# trim_lcscience.sh
# 
#
# Created by Bruno Costa on 18/06/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.

# trim adaptor from reads  
# call trim_lcscience.sh [source] [lib]

#rename input vars
SOURCE=$1
LIB=$2

#Get config vars 
. ${SOURCE}/config/workdirs.cfg

lib=$(printf "%02d\n" $LIB)
input=${workdir}data/fasta/lib${lib}.fa
output=${workdir}data/fasta/lib${lib}_trimmed.fa
report=${workdir}data/fasta/lib${lib}_report.txt

#Fix for error with illumina data
#fastx_clipper -Q33 -a $ADAPTOR -l 0 -c -v -i $input -o $output > $report  && mv  $output $input
fastx_clipper -a $ADAPTOR -l 0 -c -v -i $input -o $output > $report  && mv  $output $input


exit 0
