#!/usr/bin/env bash 

#report.sh
#
#Created by: Bruno Costa
#
# ITQB 2015/11/28
#
#call report.sh [lib first] [lib last] [source]
#call report.sh ["array"] [libs] [source]

if [[ "$1" == "array" ]]; then
  ARRAY=TRUE
  CYCLE=$2 
elif [[ -z "$3" ]]; then
  echo "Error: Missing arguments, cowardly refused to continue. $0:::Line:$LINENO"
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
if [[ -d "${workdir}data/fastq" ]]; then

  files=""
  output="${workdir}count/Fastq-$label.tsv"
  echo $output
  echo "Lib Total Distinct" > $output
  for lib in $CYCLE
    do
    lib_now=$(printf "%02d\n" $lib)
    file=${workdir}data/fastq/lib${lib_now}.fq
    if [[ -e "$file" ]]; then  
      distinct=$(grep "^[ATCG]*$" $file | sort | uniq | wc -l)
      total=$(( $(wc -l $file | awk '{print $1}') / 4 ))
      files=$files" "$file 
      echo "Lib${lib_now} $total  $distinct" >> $output
    else
      echo "Lib${lib_now} NA  NA" >> $output
    fi
  done
  total_d=$(cat $files | grep "^[ATGC]*$" | sort | uniq | wc -l)

  filesLines=$(cat $files | wc -l ) 
  if [[ "$filesLines" -gt 3 ]];then
    total=$(( $fileLines / 4 ))
  fi
  echo "Total $total $total_d" >> $output

fi

#TODO Check if adaptor reports exist.


#FASTA
#Check if file has already been collapsed
files=""
output="${workdir}count/Fasta-$label.tsv"
echo $output
echo "Lib Total Distinct" > $output
for lib in $CYCLE
  do
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}data/fasta/lib${lib_now}.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep -c ">" $file)
  files=$files" "$file 
  echo "Lib${lib_now} $total  $distinct" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep -c ">")
echo "Total $total $total_d" >> $output

#Filter WB
output="${workdir}/count/Filter-$label.tsv"
echo "Lib Total Distinct" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}data/filter_overview/lib${lib_now}*.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  echo "Lib${lib_now} $total  $distinct" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
echo "Total $total $total_d" >> $output


#Genome
output="${workdir}/count/Genome-$label.tsv"
echo "Lib Total Distinct" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}data/FILTER-Genome/lib${lib_now}*.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  echo "Lib${lib_now} $total  $distinct" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
echo "Total $total $total_d" >> $output


#Cons
output="${workdir}/count/Cons-$label.tsv"
echo "Lib Total Distinct" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}data/lib${lib_now}*_cons.fa
  distinct=$(grep -v ">" $file | sort | uniq | wc -l)
  total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  files=$files" "$file 
  echo $files
  echo "Lib${lib_now} $total  $distinct" >> $output
done
total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
echo "Total $total $total_d" >> $output

#Novel
output="${workdir}/count/Novel-$label.tsv"
echo "Lib Total Distinct" > $output
files=""
for lib in $CYCLE
  do       
  lib_now=$(printf "%02d\n" $lib)
  file=${workdir}data/mircat/lib${lib_now}*_noncons_miRNA_filtered.fa
  testNOVEL=$( wc -l ${file} | awk '{print $1}' )
  total=0
  distinct=0
  if [[ "$testNOVEL" -gt 1 ]]; then
    distinct=$(grep -v ">" $file | sort | uniq | wc -l)
    total=$(grep ">" $file | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
    files=$files" "$file 
    echo $files
  fi  
  echo "Lib${lib_now} $total  $distinct" >> $output
done
if [[ ! -z "$files" ]]; then
  total_d=$(cat $files | grep -v ">" | sort | uniq | wc -l)
  total=$(cat $files | grep ">" | awk -F "[()]" 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  echo "Total $total $total_d" >> $output
fi

#TASI
output="${workdir}/count/TASI-$label.tsv"
echo "Lib Total Distinct" > $output
files=""
sumTotal=0
for lib in $CYCLE
  do
  #reset var  
  lib_now=$(printf "%02d\n" $lib)
  testTASI=$( wc -l ${workdir}"data/tasi/lib${lib_now}-tasi.fa" | awk '{print $1}' )
  total=0
  distinct=0
  if [[ "$testTASI" -gt 1 ]]; then
    file=${workdir}"data/tasi/lib"${lib_now}*"_noncons_tasi_srnas.txt"
    distinct=$(awk -F "[(]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1}}' $file | sort | uniq | wc -l)
    total=$(awk -F "[()]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1" "$2}}' $file | sort | uniq | awk 'BEGIN{sum=0}{sum+=$2}END{print sum}')
    files=$files" "$file
    sumTotal=$(( $total + $sumTotal )) 
  fi  
  echo "Lib${lib_now} $total  $distinct" >> $output
done
if [[ ! -z "$files" ]]; then
  total_d=$(cat $files | awk -F "[(]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1}}' | sort | uniq | wc -l)
  #Not calculating
  total=$(cat $files | awk -F "[()]" '{match($0,"[0-9]*.[0-9]*)");if(RLENGTH>0){print $1" "$2}}' | sort | uniq | awk 'BEGIN{sum=0}{sum+=$2}END{print sum}')
  echo "Total $sumTotal $total_d" >> $output
fi
#Lib    Total Distinct    
#Lib1   xxxx  d(xxx)    
#Lib2   yyyy  d(yyy)    
#Total  x+y   d(xxx+yyy)


#TODO Join separate files

>&2 echo "tasi"
exit 0

