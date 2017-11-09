#!/usr/bin/env bash 

#report.sh
#
#Created by: Bruno Costa
#
# ITQB 2015/11/28
#
#call report.sh [lib first] [lib last] [source]
#call report.sh ["array"] [libs] [source]

printf $(date +"%y/%m/%d-%H:%M:%S")" Starting report\n"

if [[ "$1" == "array" ]]; then
  ARRAY=TRUE
  CYCLE=$2 
elif [[ -z "$3" ]]; then
  >&2echo "Error: Missing arguments, cowardly refused to continue. $0:::Line:$LINENO"
  exit 1        
else        
  LIB_FIRST=$1
  LIB_LAST=$2
fi

DIR=$3

. $DIR/config/workdirs.cfg






#Calculate distinct for these libraries and individual
if [[ -z "$ARRAY" ]]; then
  CYCLE=$(eval echo {$LIB_FIRST..$LIB_LAST})
  label="Lib${LIB_FIRST}-${LIB_LAST}"
else
   label=$(echo "Libs"$CYCLE | tr -s "[:blank:]" "-")       
fi



#FASTQ
if [[ -d "${workdir}/data/fastq" ]]; then

  files=""
  output="${workdir}/count/Fastq-$label.tsv"
  echo $output
  printf "Lib\tTotal\tDistinct\n" > $output
  for lib in $CYCLE
    do
    lib_now=$(printf "%02d\n" $lib)
    file=${workdir}/data/fastq/Lib${lib_now}.fq
    if [[ -e "$file" ]]; then  
      distinct=$(grep "^[ATCG]*$" $file | sort | uniq | wc -l)
      total=$(( $(wc -l $file | awk '{print $1}') / 4 ))
      files=$files" "$file 
      printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
    else
      printf "Lib${lib_now}\tNA\tNA\n" >> $output
    fi
  done
  total_d=$(cat $files | grep "^[ATGC]*$" | sort | uniq | wc -l)

  filesLines=$(cat $files | wc -l ) 
  if [[ "$filesLines" -gt 3 ]];then
    total=$(( $filesLines / 4 ))
  fi
  printf "Total\t$total\t$total_d\n" >> $output

fi

#TODO Check if adaptor reports exist.


#FASTA
#Check if file has already been collapsed
files=""
output="${workdir}/count/Fasta-$label.tsv"
echo $output
printf "Lib\tTotal\tDistinct\n" > $output
for lib in $CYCLE
  do
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}/data/fasta/Lib${lib_now}.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep -c ">" $file)
  files=$files" "$file 
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep -c ">")
printf "Total\t$total\t$total_d\n" >> $output

#Filter WB
output="${workdir}/count/Filter-$label.tsv"
printf "Lib\tTotal\tDistinct\n" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}/data/filter_overview/Lib${lib_now}*.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
printf "Total\t$total\t$total_d\n" >> $output


#Genome
output="${workdir}/count/Genome-$label.tsv"
printf "Lib\tTotal\tDistinct\n" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}/data/filter_genome/Lib${lib_now}*.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
printf "Total\t$total\t$total_d\n" >> $output


#Cons
output="${workdir}/count/Cons-$label.tsv"
printf "Lib\tTotal\tDistinct\n" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}/data/Lib${lib_now}*_cons.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
printf "Total\t$total\t$total_d\n" >> $output

#Novel
output="${workdir}/count/Novel-$label.tsv"
printf "Lib\tTotal\tDistinct\n" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}/data/mircat/Lib${lib_now}*_noncons_miRNA_filtered.fa
  testNOVEL=$( wc -l ${file} | awk '{print $1}' )
  total=0
  distinct=0
  if [[ "$testNOVEL" -gt 1 ]]; then
    distinct=$(grep -v ">" $file | sort | uniq | wc -l)
    total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
    files=$files" "$file 
    echo $files
  fi  
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
if [[ ! -z "$files" ]]; then
  total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
  total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  printf "Total\t$total\t$total_d\n" >> $output
fi

#TASI
output="${workdir}/count/TASI-$label.tsv"
printf "Lib\tTotal\tDistinct\n" > $output
files=""
sumTotal=0
for lib in $CYCLE
  do
  #reset var  
  lib_now=$(printf "%02d\n" $lib)
  testTASI=$( wc -l ${workdir}/"data/tasi/Lib${lib_now}-tasi.fa" | awk '{print $1}' )
  total=0
  distinct=0
  if [[ "$testTASI" -gt 1 ]]; then
    file=${workdir}/"data/tasi/Lib"${lib_now}*"_noncons_tasi_srnas.txt"
    distinct=$(awk -F "[(]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1}}' $file | sort | uniq | wc -l)
    total=$(awk -F "[()]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1" "$2}}' $file | sort | uniq | awk 'BEGIN{sum=0}{sum+=$2}END{print sum}')
    files=$files" "$file
    sumTotal=$(( $total + $sumTotal )) 
  fi  
  printf "Lib${lib_now}\t$total\t$distinct\n" >> $output
done
if [[ ! -z "$files" ]]; then
  total_d=$(cat $files | awk -F "[(]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1}}' | sort | uniq | wc -l)
  #Not calculating
  total=$(cat $files | awk -F "[()]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1" "$2}}' | sort | uniq | awk 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  printf "Total\t$sumTotal\t$total_d\n" >> $output
fi
#Lib    Total Distinct    
#Lib1   xxxx  d(xxx)    
#Lib2   yyyy  d(yyy)    
#Total  x+y   d(xxx+yyy)


#TODO Join separate files

exit 0

