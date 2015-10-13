#!/usr/bin/env bash                
###################################################
# count_abunance.sh                               #
# Created by: Bruno Costa on 12/10/2015           #
# Copyright 2015 ITQB / unL. All rights reserved. #
#                                                 #
#  call:                                          #
#  count_abundance.sh ["pattern"] [nproc]         #
###################################################

threads=$2
if [[ -z $threads ]]; then
  threads=$(( $(nproc) - 1 ))           
fi
#echo "Threads: ${threads}" 
  

#List of patterns to get files to open.
listFiles=$(ls $1)
#echo $listFiles
seR=$(mktemp -t seqR.XXXXXX)
seq=$(mktemp -t seq.XXXXXX)
uniqSeq=$(mktemp -t uniqSeq.XXXXXX)

#legacy code convert old cons files into compatible
testCons=$(cat $listFiles | grep -c ">all-combined")
if [[ "$testCons" > "0" ]]; then
  for i in $listFiles
  do
    testI=$(grep -c ">all-combined" $i)
    if [[ "$testI" > "0" ]]; then    

      tempCons=$(mktemp -t tempCons.XXXXXX)
      awk -F '\n' 'BEGIN{RS=">"}{if(NR>1){match($1,"^all-combined");if(RLENGTH>0){print ">"$2 "-" $1;newline;print $2}else{print ">"$1;newline;print $2}}}' $i > $tempCons && cat $tempCons > $i && rm $tempCons
    fi
  done

fi        
##Check if fasta is collapsed then 
##get counts for each
## Since the files used are from the sRNA workflow ( ) is the major trend manby don't worry with fastx colapsiing
for i in $listFiles
do 
  ##Used to get conserved names not for typical case        
  # awk -F "[-_\n]" 'BEGIN{RS=">"}{print $3" "$6}' $i >> $seqR
  awk -F "\n" 'BEGIN{RS=">"}{if(NR>1){print $2}}' $i >> $seq
done

#Get unique sequences throughout all libraries
sort $seq | uniq > $uniqSeq

#Remove used files not used anymore
rm $seq $seqR

nl=$(wc -l $uniqSeq | awk '{print $1}')
#echo $nl
cycle=$(eval  echo {1..$nl})

#lib37_43=~/sRNA37_43/data/lib15_filt-18_26_5_Ptaeda1.01-masktrim.fa_mirbase_cons.fa

function seqCount {
  #Call seqCount [libs] [line]
  libsFunc=$1
  lineFunc=$2
  #echo $libsFunc
  #echo $lineFunc
  #  echo $listFiles
  res="${lineFunc}\t"
  for j in $libsFunc 
  do
    #echo $j      
    tmp=$(echo $listFiles | awk 'BEGIN{RS=" "}{print $1}' | grep $j | awk '{printf $1" "}END{printf "\n"}' )     
    #echo $tmp
          
         
    eval $j=$(cat $tmp | grep -B0 -w -m1 $lineFunc | awk -F "[()]" '{ if( NR==1 ){print $2}}')
    testCount=$(eval "echo \$$j")    
    if [[ -z $testCount ]]; then
      testCount=0
    fi
    res="${res}${testCount}\t"
  done   
  printf "${res}\n"
}

#Get ordered list of unique libs
libs=$(echo $listFiles | awk 'BEGIN{RS=" "}{print $1}' | sed -r "s:.*(lib[0-9]*).*:\1:g" | sort | uniq | awk '{printf $1" "}END{printf "\n"}')
#echo $libs

#Create Header
header="\t"
for i in $libs
do
  header="${header}\t${i}"          
done
  printf "${header}\n"
  

pcount=0
for i in $cycle  
do 
#  echo $i
  line=$(head -$i $uniqSeq | tail -1 )
  #echo $line
  seqCount "$libs" "$line" &
  pcount=$(( $pcount + 1 ))
  
  if [[ "$pcount" == "$threads" ]]; then
    wait
  fi        
     
   #mir=$(grep -w -m1 $line $seqR | awk '{ print $1 }') 

done
rm $uniqSeq

exit 0
