#!/usr/bin/env python3

#Created by: Bruno Costa	
# ITQB 2016
# 
# This calculates the distribution profile from collapsed or not fasta files
# size-fasta.py -h for help  
# Old version go to cmsrv01 to get updated version

import os
import argparse
import re
import time

#Setting this var to get the current directory
pwd=os.getcwd()


parser = argparse.ArgumentParser(description='This is the description')
#parser.add_argument('integers', metavar='N', type=int, nargs='+',
#                    help='an integer for the accumulator')
## What is this for?
parser.add_argument('--sum', dest='accumulate', action='store_const',
                    const=sum, default=max,
                    help='sum the integers (default: find the max)')

parser.add_argument('--input',type=str, nargs=1, metavar='input',dest='inputFile',help='This is the input file')

#parser.add_argument('-i', dest="fileIN", action='store_const', type=str, nargs='1', help='This is the input')

parser.add_argument('--output',type=str, metavar='output',dest='outputFile',help='This is the output file')

args = parser.parse_args()
#Sprint(args.accumulate(args.integers))


fileIN=args.inputFile
fileOUT=args.outputFile
#print(args.inputFile)

fasta_file=fileIN

output=open(fileOUT,"w")
fasta=open(fasta_file[0],"r")
#This is a script provided by FPMartins to index fasta into a dictionary	
d = {}
#Are headers unique? If duplicated appear we add a number to the beginning (ok since headers are recycled for anything besides grabbing collapsed counts)
count=0
for lines in fasta:
	if lines.startswith('>'):
		name = lines[1:].strip()
		if name in d.keys():
			count+=1
			name=+count+name
		d[name] = ''
	else:
		d[name] += lines.strip().upper()
fasta.close()

#Dictionary that keeps the information of size count
size_dict=dict([[x,0] for x in range(0,102)])
for header in d.keys():
	#This extracts the number of times this header exists
	qt=1
	#Check if there is collapsed info (That is UEA type)
	if(len(header.split("("))>1 and re.search("\([0-9]+\.*[0-9]+\)$",header) is not None):
		qt=int(header.split("(")[1].strip(")"))
	#Length of the sequence
	seq_len=len(d[header])
	#Adding number of sequence that have that size to the size_dict[ionary]
	size_dict[seq_len]=size_dict[seq_len]+qt
	#time.sleep(1)
#print(size_dict)


fileName=fileIN[0].split("/")[-1]
fileRoot=str(fileName).split(".")[0]
output.write(fileRoot+"\n")
for key in size_dict.keys():
	line=str(key)+"\t"+str(size_dict[key])+"\n"
	output.write(line)
output.flush()
output.close()
