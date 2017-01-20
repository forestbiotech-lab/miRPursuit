  #!/usr/bin/env bash                
  ###################################################
  # count_abunance.sh                               #
  # Created by: Bruno Costa on 12/10/2015           #
  # Copyright 2015 ITQB / unL. All rights reserved. #
  #                                                 #
  #  call:                                          #
  #  count_abundance.sh ["pattern"] [type ] [nproc] #
  ###################################################
  #Class={none,cons,tasi,novel} 
  class=$2

  threads=$3
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

  #legacy code convert old cons files into compatible(This know aplies)
  testCons=$(cat $listFiles | grep -c ">all combined")
  if [[ "$testCons" > "0" ]]; then
    for i in $listFiles
    do
      testI=$(grep -c ">all combined" $i)
      if [[ "$testI" > "0" ]]; then    

        tempCons=$(mktemp -t tempCons.XXXXXX)
        awk -F '\n' 'BEGIN{RS=">"}{if(NR>1){match($1,"^all combined");if(RLENGTH>0){print ">"$2 "-" $1;newline;print $2}else{print ">"$1;newline;print $2}}}' $i > $tempCons && cat $tempCons > $i && rm $tempCons
      fi
    done
  fi        
  ##Check if fasta is collapsed then


  ##get counts for each
  ## Since the files used are from the sRNA workflow ( ) is the major trend. Maybe don't worry with fastx colapsiing
  for i in $listFiles
  do 
    awk -F "\n" 'BEGIN{RS=">"}{if(NR>1){print $2}}' $i >> $seq
  done

  #Get unique sequences throughout all libraries
  sort $seq | uniq > $uniqSeq

  #Remove used files not used anymore
  rm $seq $seqR

  nl=$(wc -l $uniqSeq | awk '{print $1}')
  #echo $nl
  cycle=$(eval  echo {1..$nl})

  function seqCount {
    #Call seqCount [libs] [line] [class]
    ##lib num
    libsFunc=$1
    ##Sequence
    lineFunc=$2
    ##Class={"cons","none","tasi","novel"}
    classFunc=$3
   


    if [[ "${class}" == "cons"  ]]; then
      #Parse files to be read by grep
      files=$(echo $listFiles | awk 'BEGIN{RS=" "}{print $1}')
      #Get mir name from first match in list of conserved
      temp=$(cat $files | grep -w -m1 $lineFunc | awk -F [-_] '{print $3}' )
      ##Construction of output line for cons sequences 
      res="${lineFunc}\t${temp}\t"
    elif [[ "${class}" == "novel"  ]]; then
      #Change path where expression is to retreived
      #This is done because mircat sometimes detectes precursores in some libraries but not in others.
      #remove _miRNA_filtered & remove /mircat/
      listFiles=$(echo ${listFiles} | sed -r "s:/mircat/:/:g" | sed -r "s:_miRNA_filtered::g")
      res="${lineFunc}\tnovel\t"
    elif [[ "${class}" == "tasi" ]]; then
      res="${lineFunc}\ttasi\t"
    elif [[ "${class}" == "none"  ]]; then
      ##Construction of output line for other sequences      
      res="${lineFunc}\t"
    else
      echo "Error - Terminated prematurely due to lack of argument class. $0:::Line:$LINENO  "      
      exit 1
    fi        
   
    for j in $libsFunc 
    do
      #echo $j      
      tmp=$(echo $listFiles | awk 'BEGIN{RS=" "}{print $1}' | grep $j | awk '{printf $1" "}END{printf "\n"}' )     
      #echo $tmp
            
      if [[ -z $lineFunc ]]; then     
        eval $j="-"
      else
        eval $j=$(cat $tmp | grep -B0 -w -m1 $lineFunc | awk -F "[()]" '{ if( NR==1 ){print $2}}')
      fi
      testCount=$(eval "echo \$$j")    
      if [[ -z $testCount ]]; then
        testCount=0 
      fi
      res="${res}${testCount}\t"
    done   
    printf "${res}\n"
  }

  #Get ordered list of unique libs
  libs=$(echo $listFiles | awk 'BEGIN{RS=" "}{print $1}' | sed -r "s:.*(Lib[0-9]*).*:\1:g" | sort | uniq | awk '{printf $1" "}END{printf "\n"}')
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
    seqCount "$libs" "$line" "$class"  &
    pcount=$(( $pcount + 1 ))
    
    if [[ "$pcount" == "$threads" ]]; then
      wait
    fi        
       
    #mir=$(grep -w -m1 $line $seqR | awk '{ print $1 }') 

  done
  wait

  rm $uniqSeq

  exit 0
