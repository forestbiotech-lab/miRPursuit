#!/usr/bin/env bash
log=$1
j=4
i=0
args=""
while [[ $# > 0 ]]
do
  key="$1"
  args="$args --form upload=@$key"	
  shift
done

echo $args
curl $args "https://srna-portal.biodata.pt/mirpursuit/logs/upload"
