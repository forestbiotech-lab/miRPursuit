#!/usr/bin/env bash

# sRNAworkFlow.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes the complete pipline
# Call: sRNAworkFlow.sh [inserts_dir] [LIB_FIRST] [LIB_LAST] [STEP]

set -e

# OUTPUT-COLORING
red='\e[0;31m'
blue='\e[0;34m'
green='\e[0;32m'
blink='\e[5m'
unblink='\e[25m'
invert='\e[7m'
NC='\e[0m' # No Color
noPrompt=FALSE

while [[ $# > 0 ]]
do
  key="$1"

case $key in
  -f|--lib-first)
  LIB_FIRST="$2"
  shift # past argument
  ;;
  -l|--lib-last)
  LIB_LAST="$2"
  shift # past argument
  ;;
  -s|--step)
  step="$2"
  shift # past argument
  ;;
  --fastq)
  fastq="$2"
  shift #past argument
  ;;
  --fasta)
  fasta="$2"
  shift #past argument
  ;;
  --trim)
  TRIM=TRUE #Don't shift one argument
  ;;
  --headless)
  HEADLESS_MODE=TRUE
  ;;
  --no-prompt)
  noPrompt=TRUE
  ;;
  --lc)
  LC="$2"
  shift # past argument
  ;;
  -h|--help)
  echo -e " 
  ${blue}-f|--lib-first
  -l|--lib-last
  -h|--help${NC}
  ---------------------
  Optional args
  ---------------------
  ${blue}-s|--step${NC} Step is an optional argument used to jump steps to start the analysis from a different point  
      ${green}Step 1${NC}: Adaptor trimming (If flagged) & Wbench Filter
      ${green}Step 2${NC}: Filter Genome & mirbase
      ${green}Step 3${NC}: Tasi
      ${green}Step 4${NC}: Mircat
      ${green}Step 5${NC}: PAREsnip    
 ${blue}--lc${NC} Set the program to begin in lcmode instead of fs mode. The preceding substring from the lib num. (Pattern) Template + Lib num, but identify only one file in the inserts_dir    
 ${blue}--fasta${NC} Set the program to start using fasta files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fa, Lib_2.fa, .. --> argument should be Lib_
 ${blue}--fastq${NC} Set the program to start using fastq files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fq, Lib_2.fq, .. --> argument should be Lib_ , if no .fq file is present but instead a .fastq.gz file will additionally be extracted automatically.
 ${blue}--trim${NC}  Set this flag to perform adaptor trimming. No argument should be given. The adaptor is in the workdirs.cfg config file in the variable ADAPTOR.
 ${blue}--headless${NC}  Set this flag to run on headless server. Requires Xvfb be installed on your system.
 ${blue}--no-prompt${NC}  Set this flag to skip all prompts.

  "
  exit 0
esac
shift # past argument or value
done




if [[ -z $LIB_FIRST || -z $LIB_LAST ]]; then
  echo -e "${red}Invalid input${NC} - Missing mandatory parameters"
  echo -e "use ${blue}-h|--help${NC} for list of commands"
  exit 127
else
  if [[ ! $LIB_FIRST =~ ^[0-9]+$ ]]; then
    echo -e "${red}Invalid input${NC} - Missing mandatory parameters for -f|--first"
    echo -e "use ${blue}-h|--help${NC} for list of commands"
    exit 127
  fi
  if [[ ! $LIB_LAST =~ ^[0-9]+$ ]]; then  
    echo -e "${red}Invalid input${NC} - Missing mandatory parameters for -l|--last"
    echo -e "use ${blue}-h|--help${NC} for list of commands"
    exit 127
  fi  
fi
##Should check if libraries exit


if [[ ! -z "$step" ]]; then
  if [[ "$step" -gt 5 || "$step" -lt 1 ]]; then
     >&2 echo -e "${red}Terminating${NC} - That step doen't exist please specify a lower step"         
     exit 127
  fi
fi


#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#Get config settings
. $DIR/"config/workdirs.cfg"
SOFT_CFG=${DIR}"/config/software_dirs.cfg"
. $SOFT_CFG

##Progress report starting and declaring variable
progress=${workdir}PROGRESS

#Set this to use HEADLESS version
if [[ $HEADLESS_MODE == "TRUE" ]]; then
  sed -ri "s:(HEADLESS=)(.*):\1${HEADLESS_MODE}:" ${SOFT_CFG} 
fi

#Check programs are set up and can run (Java and Wbench).
if [[ -z "$JAVA_DIR"  ]]; then
  echo -e "${red}Not set${NC}: Please set java var in ${blue}software_dirs.cfg${NC} config file or run install script"
  exit 127
else
  if [[ -x "$JAVA_DIR" && -e "${JAVA_DIR}" ]]; then
    echo -e "Java set up: ${green}OK${NC}"
  else
    echo -e "${red}Failed${NC}: Java can't be run or invalid path"
    exit 127
  fi        
fi
if [[ -z "$WBENCH_DIR" ]]; then
  echo -e "${red}Not set${NC}: Please set workbench var in ${blue}software_dirs.cfg${NC} config file or run install script"
  exit 127        
else        
  if [[ -x "$WBENCH_DIR" && -e "$WBENCH_DIR" ]]; then
    echo -e "Workbench set up ${green}OK${NC}"   
  else
    echo -e "${red}Failed${NC}: Workbench can't be run or invalid path. Please check the workbench var in the ${blue}software_dirs.cfg${NC} config file."
    exit 127
  fi
fi

echo "Running pipeline with the following arguments:"
printf "FIRST Library\t\t\t= ${LIB_FIRST}\n"
printf "Last Library\t\t\t= ${LIB_LAST}\n"
printf "Number of threads\t\t= ${THREADS}\n"


if [[ -e "${DIR}/config/filters/wbench_filter_${FILTER_SUF}.cfg" ]]; then
  echo "Filter suffix                 = ${FILTER_SUF}"
  cp ${DIR}/config/filters/wbench_filter_${FILTER_SUF}.cfg ${DIR}/config/wbench_filter_in_use.cfg
else
  >&2 echo -e "${red}Error${NC} - The given filter file doesn't exist please check the file exists. Correct the FILTER_SUF var in ${blue}workdirs.cfg${NC} config file."  
  exit 127
fi
if [[ -e "${GENOME}" ]]; then        
  echo "Genome                      = "${GENOME}
else
  >&2 echo -e "${red}Error${NC} - The given genome file doesn't exist please check the file exists. Correct the GENOME var in ${blue}workdirs.cfg${NC} config file."
  exit 127
fi
if [[ -e "${GENOME_MIRCAT}" ]]; then        
  echo "Genome mircat               = "${GENOME_MIRCAT}
else
  echo -e "${red}Error${NC} - The given genome file for mircat doesn't exit please check the file exists. Correct the GENOME_MIRCAT var in ${blue}workdirs.cfg${NC} config file."
fi
if [[ -e "${MIRBASE}" ]]; then        
  echo "miRBase                     = "${MIRBASE}
else
  echo -e "${red}Error${NC} - The given mirbase file doesn't exist please check the file exists. Correct the MIRBASE var in ${blue}workdirs.cfg${NC} config file."
  exit 127
fi
if [[ -z "${workdir}" ]]; then
  echo -e "${red}Not set:${NC} No workdir hasn't been set please don't put a trailing /, see config workdirs.cfg."
  exit 127
else
  echo "Working directory (workdir) =  ${workdir}"      
fi        
if [[ -d "${INSERTS_DIR}" ]]; then
  echo "sRNA directory (INSERTS_DIR)=  ${INSERTS_DIR}"
  #Not dealing files from multiple files with same pattern but different extensions
  #Checking if any thing matches first then it will check if multiple files are being found in pipe_fast*
  testLib=$(echo ${INSERTS_DIR}/*${fasta}${fastq}${LC}${LIB_FIRST}*)
  if [[ ! -z "$testLib" ]]; then
    echo "First lib to be processed   = "${testLib}
  else
    >&2 echo -e "${red}Invalid pattern:${NC} - No file / multiple files found, in inserts dir that matches your input settings ${green}${fasta}${fastq}${LC}${NC} for lib ${LIB_FIRST}. Or perhaps you're starting lib ${LIB_FIRST} is to low."
    exit 127
  fi      
else        
  echo -e "${red}Invalid dir${NC}: The inserts directory hasn't been configured properly, see config file ${blue}workdirs.cfg${NC}."
  exit 127
fi        
#nonempty string bigger than 0 (Can't remember purpose of this!)
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi
if [[ -d "$workdir" && "${noPrompt}" == "FALSE" ]]; then
  unset $booleanYorN
  >&2 echo -e "${red}Attention!${NC}\nworkdir - $workdir \nData already exists data in this folder might be overwritten." 
  while [[ "$booleanYorN" != [yYnN] ]]
  do        
    read -n1 -p "Continue? (Y/N)" booleanYorN
  done
  if [[ $booleanYorN == [nN] ]]; then
    echo $(date +"%y|%m|%d-%H:%M:%S")" - Terminated prematurely due to possibility of workdir being overwritten."
    >&2 printf "\nTerminating prematurely"
    exit 1
  fi
fi
mkdir -p $workdir"log/"
printf "0\tStarted\t0" >$progress
runDate=$(date +"%y|%m|%d-%H:%M:%S")
log_file="${workdir}log/${runDate}:$$:Global:${LIB_FIRST}-${LIB_LAST}.log"


#Make dir to store all logs generated by subscripts.
mkdir -p $workdir"log/$runDate"
exec >&1 > ${log_file}
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
printf "\nRan with these vars:\n###################\n#software_dirs.cfg#\n###################\n"
cat $SOFT_CFG
printf "\nRan with these vars:\n##############\n#workdirs.cfg#\n##############\n"
cat $DIR/"config/workdirs.cfg"
printf "\n\n"

SCRIPTS_DIR=$DIR"/scripts"

#Test if the var step exists
if [[ -z "$step" ]]; then 
  step=0
fi
if [[ ! -z "$LC" ]]; then
  >&2 echo -e "${blue}Running in LC mode.${NC}"
  ${DIR}/extract_lcscience_inserts.sh $LIB_FIRST $LIB_LAST $LC
  step=1
fi
if [[ ! -z "$fastq" ]]; then
  >&2 echo -e "${blue}Running in fastq mode.${NC}"
  ${DIR}/pipe_fastq.sh $LIB_FIRST $LIB_LAST $fastq
  step=1
fi
if [[ ! -z "$fasta" ]]; then
  >&2 echo -e "${blue}Running in fasta mode.${NC}"
  ${DIR}/pipe_fasta.sh $LIB_FIRST $LIB_LAST $fasta
  ##Make profile
  step=1
fi

if [[ "$step" -eq 0 ]]; then        
  #Concatenate and convert to fasta
  >&2 echo -ne "${blue} Step 0${NC} - Concatenating libs and converting to fasta\t[                         ]  0%\r"
  printf "0\tConverting\t0" > $progress
  ${DIR}/extract_fasteris_inserts.sh $LIB_FIRST $LIB_LAST
  step=1
fi 
if [[ "$step" -eq 1 ]]; then
  if [[ $TRIM ]]; then  
    if [[ -z "$ADAPTOR" ]]; then
      echo -e "${red}Invalid Adaptor${NC}: - The adaptor variable hasn't  been configured properly, see config file ${blue}workdirs.cfg${NC}."
      exit 127
    else
      >&2 printf "Adaptor sequence            = ${ADAPTOR} \n\n"
      >&2 echo -ne "${blue} Step 1${NC} - Adaptor removal                           \t[##                       ] 10%\r"  
      printf "10\tAdaptor\t1" >$progress

      ${DIR}/pipe_trim_adaptors.sh $LIB_FIRST $LIB_LAST
    fi
  fi
  #Filter size, t/rRNA, abundance.
  >&2 echo -ne "${blue} Step 1${NC} - Filtering libs with workbench Filter      \t[#####                    ] 20%\r"
  printf "20\tFiltering\t1" >$progress

  ${DIR}/pipe_filter_wbench.sh $LIB_FIRST $LIB_LAST
  step=2
fi
if [[ "$step" -eq 2 ]]; then 
  #Filter genome and mirbase
  >&2 echo -ne "${blue}Step 2${NC} - Filtering libs against genome and mirbase  \t[##########               ] 40%\r"
  printf "40\tGenome miRBase\t2" >$progress

  ${DIR}/pipe_filter_genome_mirbase.sh $LIB_FIRST $LIB_LAST
  step=3
fi
if [[ "$step" -eq 3 ]]; then 
  #tasi
  >&2 echo -ne "${blue} Step 3${NC} - Running tasi, searching for tasi reads    \t[###############          ] 60%\r"
  printf "60\tTasi\t3" >$progress
  ${DIR}/pipe_tasi.sh $LIB_FIRST $LIB_LAST 
  step=4
fi
if [[ "$step" -eq 4 ]]; then 
  #mircat
  >&2 echo -ne "${blue} Step 4${NC} - Running mircat (Be patient, slow step)    \t[####################     ] 80%\r"
  printf "80\tmiRCat\t4" >$progress

  ${DIR}/pipe_mircat.sh $LIB_FIRST $LIB_LAST
  step=5
fi  
if [[ "$step" -eq 5 ]]; then
  >&2 echo -ne "${blue} Step 5${NC} - Counting sequences to produces matrix     \t[######################   ] 90%\r"
  printf "90\tCounting\t5" >$progress
  ${DIR}/counts_merge.sh 
  >&2 echo -ne "${blue} Step 5${NC} - Running report                            \t[######################## ] 95%\r"
  printf "95\tReporting\t5" >$progress
  $SCRIPTS_DIR/report.sh $LIB_FIRST $LIB_LAST ${DIR}
fi

  >&2 echo -e "${blue} Step 5${NC} - Done, files are in workdir                \t[#########################]  100%"
  printf "100\tFinished\t5" >$progress
  sleep 4
  >&2 echo "    "
  >&2 echo "This workflow was created by Forest Biotech Lab - iBET, Portugal                                         "
  sleep 2
  >&2 echo "Build around the UEA srna-workbench. http://srna-workbench.cmp.uea.ac.uk/the-uea-small-rna-workbench-version-3-2/" 
  sleep 2
  >&2 echo "Feedback: brunocosta@itqb.unl.pt"
  sleep 2
  >&2 echo ""
               
ok_log=${log_file/.log/:OK.log}

#Copy all ok log into folder of this run (Cleaning up the log folder) 
mv ${workdir}log/*PPID$$*.log ${workdir}log/$runDate

echo $(basename $ok_log)
duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nmiRPursuit ran in ${SECONDS}secs\nmiRPursuit ran in ${duration}\n"
>&2 echo -e "${green}Finished${NC} - sRNA-workflow finished successfully. Runtime: ${duration}"
mv $log_file $ok_log

RUN=$(( $RUN + 1 ))
sed -ri "s:(RUN=)(.*):\1${RUN}:" ${SOFT_CFG}
exit 0