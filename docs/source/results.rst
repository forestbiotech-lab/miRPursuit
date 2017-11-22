============
Results
============

This pipeline generates several result tables, sequence lists and a report in LaTeX. 

Outputted files
================

Tab separated files with raw read counts:
	* Counts of Novel sequences only
		- novel=${workdir}/count/all_seq_counts_novel.tsv 			
	* Counts of filtered reads
		- noncons=${workdir}/count/all_seq_counts_nonCons.tsv 		
	* Counts of Tasi sequences only
		- tasi=${workdir}/count/all_seq_counts_tasi.tsv 				
	* Counts of simultaneously Novel and Tasi sequences only
		- novelTasi=${workdir}/count/all_seq_counts_novelTasi.tsv 	
	* Counts of conserved sequences only
		- cons=${workdir}/count/all_seq_counts_cons.tsv 				
	* Merge of all counts together
		- reunion=${workdir}/count/all_seq.tsv 						

Files with lists of sequences: 
	* List  of conserved sequences only
		- consSeq=${workdir}/count/all_seq_cons.seq 					
	* List of sequences that have been identified as a star sequence
		- star=${workdir}/count/all_seq_star.seq 						
	* List of Novel sequences only 
		- novelSeq=${workdir}/count/all_seq_novel.seq 				
	* List of Tasi sequences only
		- tasiSeq=${workdir}/count/all_seq_tasi.seq 					
	* List of simultaneously Novel and Tasi sequences only 
		- novelTasiSeq=${workdir}/count/all_seq_novelTasi.seq 		

Temporary files that are created and removed during execution:
	* Temp file to store novel sequences
		- novelTmpSeq=`mktemp /tmp/novelSeq.XXXXXX` 					
	* Temp file to store novel counts
		- novelTmp=`mktemp /tmp/novel.XXXXXX`	 						
	* Temp file to store tasi sequences
		- tasiTmpSeq=`mktemp /tmp/tasiSeq.XXXXXX` 					
	* Temp file to store tasi counts
		- tasiTmp=`mktemp /tmp/tasi.XXXXXX` 							

Other files of interest are located in:
	* Files related with precursor prediction (miRCat)
		- ${workdir}/data/mircat
	* Files related with tasi prediction
		- ${workdir}/data/tasi

Report
======

The report is written in LaTeX and is ready to be converted to pdf. However to keep this pipeline light `Tex Live <https://www.tug.org/texlive/>`_ is not included and therefore should be installed to convert it to pdf. Most package managers include these tools so this shouldn't give you a hard time.

The tex file is written to:
	- ${workdir}/count/miRPursuit_REPORT-Run[PPID].tex


