#Re use the

#Max is 3
mismatch

inputfile="lib05_filt-19_25_5_scaff-1k"
Workbench="${HOME}/software/srna-workbenchV3.2_Linux/Workbench.jar"
JAVA="${HOME}/.software/jre1.8.0_60/bin/java"
max amount of mismatches
x=3

# First run get non conserved reads from nonconserved version of lib set it as zero.
#
#
#

for i in {0..3}
do
  mismatch=i; 
  config=config/wbench_mirprof-${mismatch}.cfg

  #Run mirprof
  ${JAVA} -jar ${Workbench} -tool mirprof -srna_file_list ${inputFile}-$(( ${mismatch} - 1 ))-discard_srnas.fa -mirbase_db ~/source_data/mirbase/mirbase21/mature.fa -out_file ${inputFile}-${mismatch} -params ${config}; 
  #Get sequences from fasta
  grep -v "^>" ${inputFile}-${mismatch}_srnas.fa > ${inputFile}-discard-${mismatch}.seq; 
  
  grep -vwf ${inputFile}-discard-${mismatch}.seq ${inputFile}-$(( $mismatch - 1  ))-discard_srnas.fa > ${inputFile}-${mismatch}-discard_srnas.fa
done
----------------------------------------------------------------------------

inputFile="lib04_filt-19_25_5_scaff-1k"; 
mismatch=1; 
~/.software/jre1.8.0_60/bin/java -jar ~/software/srna-workbenchV3.2_Linux/Workbench.jar -tool mirprof -srna_file_list ${inputFile}-$(( ${mismatch} - 1 ))-discard_srnas.fa -mirbase_db ~/source_data/mirbase/mirbase21/mature.fa -out_file ${inputFile}-${mismatch} -params config/wbench_mirprof-${mismatch}.cfg
grep -v "^>" lib04_filt-19_25_5_scaff-1k-${mismatch}_srnas.fa > lib04-discard-${mismatch}.seq
grep -vwf discard-${mismatch}.seq lib04_filt-19_25_5_scaff-1k-$(( $mismatch - 1  ))-discard_srnas.fa > lib04_filt-19_25_5_scaff-1k-${mismatch}-discard_srnas.fa
cat lib04_fil*-[0-9]_srnas.fa > lib04-merge.fa
awk -F "\n" 'BEGIN{RS=">"}{print $2"|"$1}' lib04-merge.fa | awk -F "[-_|()]" '{print $1"-"$3"\t"$6}' > lib04-count.tsv

