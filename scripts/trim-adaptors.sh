#!/usr/bin/env bash

# trim_adaptors.sh
# 
#
# Created by Bruno Costa on 18/06/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.

# trim adaptor from reads  
# call trim_adaptors.sh [source] [lib]

#rename input vars
SOURCE=$1
LIB=$2

#Get config vars 
. ${SOURCE}/config/workdirs.cfg

lib=$(printf "%02d\n" $LIB)
input=${workdir}data/fasta/Lib${lib}.fa
output=${workdir}data/fasta/Lib${lib}_trimmed.fa
report=${workdir}data/fasta/Lib${lib}_report.txt

#Fix for error with illumina data
#fastx_clipper -Q33 -a $ADAPTOR -l 0 -c -v -i $input -o $output > $report  && mv  $output $input
echo "fastx_clipper -a $ADAPTOR -l 0 -c -v -i $input -o $output > $report  && mv  $output $input"
fastx_clipper -a $ADAPTOR -l 0 -c -v -i $input -o $output > $report  && mv  $output $input
# Haven't seen evidence of needing to change these options for now.
# May create a config file latter on. But my recommendation it to change to another clipper that allows mismatches
#	   [-h]         = This helpful help screen.
#	   [-a ADAPTER] = ADAPTER string. default is CCTTAAGG (dummy adapter).
#	   [-l N]       = discard sequences shorter than N nucleotides. default is 5.
#	   [-d N]       = Keep the adapter and N bases after it.
#			  (using '-d 0' is the same as not using '-d' at all. which is the default).
#	   [-c]         = Discard non-clipped sequences (i.e. - keep only sequences which contained the adapter).
#	   [-C]         = Discard clipped sequences (i.e. - keep only sequences which did not contained the adapter).
#	   [-k]         = Report Adapter-Only sequences.
#	   [-n]         = keep sequences with unknown (N) nucleotides. default is to discard such sequences.
#	   [-v]         = Verbose - report number of sequences.
#			  If [-o] is specified,  report will be printed to STDOUT.
#			  If [-o] is not specified (and output goes to STDOUT),
#			  report will be printed to STDERR.
#	   [-z]         = Compress output with GZIP.
#	   [-D]		= DEBUG output.
#	   [-i INFILE]  = FASTA/Q input file. default is STDIN.
#	   [-o OUTFILE] = FASTA/Q output file. default is STDOUT.

exit 0
