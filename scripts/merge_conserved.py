#!/usr/bin/env python3

  ####################################################
  #             merge_conserved.py                   #
  #                                                  #
  # Created by: Bruno Costa on 06/06/2017            #
  # Copyright 2017 ITQB / UNL. All rights reserved.  #
  #                                                  #
  #  call:                                           #
  #  merge_conserved.py ["pattern"] [type ] [nproc]  #
  #                                                  #
  #  Pattern: is a dir with wildcard to get specific #
  #           files                                  #
  #                                                  #
  #  Class/type: {none,cons,tasi,novel}              # 
  #                                                  #
  ####################################################

import argparse

parser = argparse.ArgumentParser(description='This is used to merge read counts of conserved miRNAs, given a readcount table of conserved reads.i.e. the one in ${workdir}/count/all_counts_cons.tsv .')


#parser.add_argument('--flag', type=str, nargs=1, metavar='', dest='', required=True, help='')
parser.add_argument('-i', type=str, metavar='input file', dest='input', required=True, help='Path to the tsv')

args = parser.parse_args()

#Define variables
tsv=args.input

writer=open(tsv.replace(".tsv","_merged.tsv"),"w")
tsv=open(tsv,"r")

tsv=[ line.strip().split("\t") for line in tsv ]

header="".join(str(i)+"\t" for  i in tsv[0])
d={}
for line in tsv[1:]:
    family=line[1]
    counts=line[2:]
    #Determine if family is a aglomeration of families
    if family.find("|")==-1 :
        family=family.split("_")[0] 
    if family in d.keys():
        d[family]=[int(x)+int(y) for x,y in zip(d[family],counts)]
    else:
        d[family]=counts
        
keys=list(d.keys())
keys.sort()
writer.write("\t\t"+header+"\n")
for key in keys:
    counts=''.join(str(i)+"\t" for i in d[key]) 
    writer.write(key+"\t"+counts+"\n")


