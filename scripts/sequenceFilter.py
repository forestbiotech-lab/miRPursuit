#!/usr/bin/env python3

#Created by: Bruno Costa	
# iBET 2018
# 
# 
#
# sequenceFilter.py -h for help  
# 

import argparse


parser = argparse.ArgumentParser(description='Grep like tool that filters a list. Using a efficient memory usage based on the known list structure. The list must have the sequences in the first column.')
#parser.add_argument('integers', metavar='N', type=int, nargs='+',
#                    help='an integer for the accumulator')
## What is this for?
parser.add_argument('--sequences','-s', 
					type=argparse.FileType('r', encoding='UTF-8'), 
					dest='sequences', 
					metavar='input',
					required=True,
                    help='List of novel sequences 1 per line')

parser.add_argument('--data','-d', 
					type=argparse.FileType('r',encoding='UTF-8'), 
					metavar='input',
					dest='data',
					required=True,
					help='List file tab separated first column should be the sequence.')
parser.add_argument('--output','-o', 
					type=argparse.FileType('w',encoding='UTF-8'), 
					metavar='output',
					dest='outputFile',
					required=False,
					help='This is the output file. If output is sent to stdout')
parser.add_argument('--invert','-v', 
					action='store_true',
					dest='invert',
					required=False,
					help='Invert match, does the inverse of the default action')


args = parser.parse_args()


sequences=args.sequences
data=args.data 
stdout=False
d=dict()
header=""
hasHeader=False



invert=args.invert
if args.outputFile is None:
	stdout=True
else:
	fw=args.outputFile


for line in data:
	if not hasHeader:
		hasHeader=True
		header=line
	else:
		line=line.strip().split("\t",1)
		if len(line)==2:
			d[line[0]]=line[1]

if stdout:
	print(header.rstrip())
else:
	fw.write(header)

counter=0
buffer=10000
for sequence in sequences:
	counter+=1
	if counter==buffer:
		counter=0
		if not stdout:
			fw.flush()
	sequence=sequence.strip()
	try:
		if invert:
			del d[sequence]
		else:
			outputLine=sequence+"\t"+d[sequence]+"\n"
			if stdout:
				print(outputLine.strip())
			else:
				fw.write(outputLine)
	except KeyError:
		pass

if invert:
	for key in d:
		outputLine=key+'\t'+d[key]+'\n'
		if stdout:
			print(outputLine.strip())
		else:
			counter+=1
			if counter== buffer:
				couter=0
				fw.flush()
			fw.write(outputLine)
else:
	if not stdout:
		fw.flush()
		fw.close()
		sequences.close()
		data.close()