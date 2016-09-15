#!/usr/bin/env bash

##
#
#size_profile.sh
#
#Author: Bruno Costa
#Copyright ITQB 2016
#
#Call size_profile.sh [fasta file] [Start (optional)] [End (optional)]
#Call size_profile.sh [Pipe from stdin] [options don't work either std or arguments]
#
##


if [[ -n "$input" ]]; then
  if [[ "$#" -ge "2"  ]];then
    START=$1
    END=$2
    awk -vS=$START -vE=$END -F ">" '{match(">",$1,a);if( RLENGTH == -1){l=length($0);b[l]++}}END{printf "Size(bp)\tCount\n";for(i=S;i<=E;i++){printf i"\t"b[i]"\n"}}' $FASTA  
  else  
    awk -F ">" '{match(">",$1,a);if( RLENGTH == -1){l=length($0);b[l]++}}END{printf "Size(bp)\tCount\n";for(i=0;i<=50;i++){printf i"\t"b[i]"\n"}}' <<< $input
  fi
else
  FASTA=$1
  START=$2
  END=$3
  if [[ "$#" -gt "1" ]]; then 
    awk -vS=$START -vE=$END -F ">" '{match(">",$1,a);if( RLENGTH == -1){l=length($0);b[l]++}}END{printf "Size(bp)\tCount\n";for(i=S;i<=E;i++){printf i"\t"b[i]"\n"}}' $FASTA  
  else
    awk -F ">" '{match(">",$1,a);if( RLENGTH == -1){l=length($0);b[l]++}}END{printf "Size(bp)\tCount\n";for(i=0;i<=50;i++){printf i"\t"b[i]"\n"}}' $FASTA
  fi
fi

exit 0
