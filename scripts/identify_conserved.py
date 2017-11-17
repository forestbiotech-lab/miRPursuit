#!/usr/bin/env python3

  ####################################################
  #          identify_conserved.py                   #
  #                                                  #
  # Created by: Bruno Costa on 16/11/2017            #
  # Copyright 2017 iBET.       All rights reserved.  #
  #                                                  #
  #  call:                                           #
  #  merge_conserved.py   #
  #                                                  #
  #   
  #                                                  #
  ####################################################

import argparse

parser = argparse.ArgumentParser(description='This is used to identify conserved miRNAs, given a read count table of conserved reads .i.e. the one in ${workdir}/count/all_counts_cons.tsv')

#parser.add_argument('--flag', type=str, nargs=1, metavar='', dest='', required=True, help='')
parser.add_argument('--cons', type=str, metavar='input file', dest='cons', required=True, help='Path to the cons counts tsv')
parser.add_argument('--fasta', type=str, metavar='input file', dest='fasta', required=True, help='Path to miRCat fasta')
parser.add_argument('--csv_mircat', type=str, metavar='input file', dest='miRCat', required=True, help='Path to miRCat file')

args = parser.parse_args()

#Define variables
tsv_cons=args.cons
tsv_cons=open(tsv_cons,"r")
fa_miRCat=args.fasta
fa_miRCat_writer=open(fa_miRCat.replace(".fa","_annotated.fa"),"w")
fa_miRCat=open(fa_miRCat,"r")
csv_miRCat=args.miRCat
tsv_miRCat_writer=open(csv_miRCat.replace(".csv","_annotated.tsv"),"w")
csv_miRCat=open(csv_miRCat,"r")


#Parse file
tsv_cons=[line.strip().split("\t") for line in tsv_cons]
#Element with the sequence and name
d={}
for line in tsv_cons[1:]:
    sequence=line[0]
    family=line[1]
    #Determine if family is an agglomeration of families
    d[sequence]=family

##Process fasta
fa_miRCat=[line.strip() for line in fa_miRCat]
for line in fa_miRCat:
  if line.startswith(">"):
    sequence=line.split(">")[1].split("(")[0]
    try:
      family=d[sequence]
    except KeyError:
      family="novelXXXXX"
    fa_miRCat_writer.write(line.replace("(","_"+family+"(")+"\n")
  else:
    fa_miRCat_writer.write(line+"\n")

fa_miRCat_writer.flush()  
fa_miRCat_writer.close()  

##Process mirCat
csv_miRCat=[line.strip().split(",") for line in csv_miRCat]

tsv_header="".join(str(i)+"\t" for  i in csv_miRCat[0])+"\n"
tsv_miRCat_writer.write("Annotation\t"+tsv_header)
for line in csv_miRCat[1:]:
  sequence=line[6]
  try:
    family=d[sequence]+"\t"
  except KeyError:
    family="novelXXXXX\t"
  newline="".join(str(i)+"\t" for  i in line)
  tsv_miRCat_writer.write(family+"\t"+newline+"\n")

tsv_miRCat_writer.flush()  
tsv_miRCat_writer.close()  

