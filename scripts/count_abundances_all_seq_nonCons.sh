#!/usr/bin/sh

target=~/test-data/allNonCons/
file=${target}lib01_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_noncons_output_filtered.csv
seqs=${target}analysis/seqs.txt
seqsU=${target}analysis/seqs.uniq
echo "">$seqs
for i in {1..19} {25..43}
do
 libNow=$(printf "%02d\n" $i)       
 awk -F "," '{print $7}' ${file/lib[0-9][0-9]/lib${libNow}} >> $seqs
 
done
sort $seqs | uniq > $seqsU

printf "lib01\tlib02\tlib03\tlib04\tlib05\tllib06\tlib07\tlib08\tlib09\tlib10\tlib11\tlib12\tlib13\tlib14\tlib15\tlib16\tLC1\tLC2\tLC3\tlib25\tlib26\tlib27\tlib28\tlib29\tlib30\tlib31\tlib32\tlib33\tlib34\tlib35\tlib36\tlib37\tlib38\tlib39\tlib40\tlib41\tlib42\tlib43\n"
threads=20


count(){
     # count [lib] [file ]
     libNow=$(printf "%02d\n" $1)     
     lib=$(grep -w -m1 $line ${2/lib[0-9][0-9]/lib${libNow}} | awk -F "," '{print $6}') 
     if [ -z "$lib" ]; then
        lib=0
     fi

}
for i in {2..12153}
do
  line=$(head -$i $seqsU | tail -1 )
  write=$line
  for j in {1..19} {25..43}
  do
     count $j $file     
 #    libNow=$(printf "%02d\n" $j)     
 #    lib=$(grep -w -m1 $line ${file/lib[0-9][0-9]/lib${libNow}} | awk -F "," '{print $6}') 
 #    if [ -z "$lib" ]; then
 #       lib=0
 #    fi
  write+="\t"$lib   
  done
  printf $write"\n"

done


        

