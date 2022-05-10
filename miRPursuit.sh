#!/usr/bin/env bash

# sRNAworkFlow.sh
# 
#
# Created by Bruno Costa on 25/05/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes the complete pipeline
# Call: miRPursuit.sh [LIB_FIRST] [LIB_LAST] [STEP]

set -e

# OUTPUT-COLORING
red='\e[0;31m'
blue='\e[0;34m'
green='\e[0;32m'
white='\e[1;37m'
black='\e[0;30m'
light_blue='\e[1;34m'
light_green='\e[1;32m'
cyan='\e[0;36m'
light_cyan='\e[1;36m'
red='\e[0;31m'
light_red='\e[1;31m'
purple='\e[0;35m'
light_purple='\e[1;35m'
brown='\e[0;33m'
yellow='\e[1;33m'
gray='\e[0;30m'
light_gray='\e[0;37m'
blink='\e[5m'
unblink='\e[25m'
invert='\e[7m'
NC='\e[0m' # No Color
noPrompt=FALSE
specificFiles=FALSE

err_report() {
   >&2 echo -e "${red}==> Error${NC} on line $1 caused a code $2 exit - $3"
   >&2 echo $(tail -1 ${log_file})
   echo "Error -  on line $1 caused a code $2 exit"
          
          
}
trap 'err_report $LINENO $? $(basename $0)' ERR


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
  --lib)
  SPECIFIC_LIB="$2"
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
  --no-genome-filter)
  IGNORE_GENOME=TRUE
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
      ${green}Step 5${NC}: Report   
 ${blue}--lib${NC} lib is an optional argument used to specify the number to be attributed to the specified file.  
 ${blue}--lc${NC} Set the program to begin in lcmode instead of fs mode. The preceding substring from the lib num. (Pattern) Template + Lib num, but identify only one file in the inserts_dir    
 ${blue}--fasta${NC} Set the program to start using fasta files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fa, Lib_2.fa, .. --> argument should be Lib_
 ${blue}--fastq${NC} Set the program to start using fastq files. As an argument supply the file name that identifies the series to be used. Ex: Lib_1.fq, Lib_2.fq, .. --> argument should be Lib_ , if no .fq file is present but instead a .fastq.gz file will additionally be extracted automatically.
 ${blue}--trim${NC}  Set this flag to perform adaptor trimming. No argument should be given. The adaptor is in the workdirs.cfg config file in the variable ADAPTOR.
 ${blue}--headless${NC}  Set this flag to run on headless server. Requires Xvfb be installed on your system. Along with libswt-gtk-3-java and gkt3.
    sudo apt-get update
    sudo apt-get install xvfb libswt-gtk-java gkt3
 ${blue}--no-prompt${NC}  Set this flag to skip all prompts.
 ${blue}--no-genome-filter${NC}  Set this flag ignore genome filtering
 -------------------------
 Specific file mode
 -------------------------
 ${blue}--fasta${NC} (In specific mode. i.e. no -f and -l) Set the program to start using fasta files. If no sequence of libraries are given then the argument can be a specific fasta file (uncompressed for now).
 ${blue}--fasta${NC} (In specific mode. i.e. no -f and -l) Set the program to start using fasta files. If no sequence of libraries are given then the argument can be a specific fasta file (uncompressed for now).
 ${blue}--lib${NC} (Optional) (In specific mode. i.e. no -f and -l) Set the library number to be attributed to the file. Should be coupled with --fasta or --fastq.
 "
  exit 0
esac
shift # past argument or value
done



if [[ -z $LIB_FIRST && -z $LIB_LAST ]]; then
  echo -e "${blue}:: Specific files${NC} - Running with listed files "
  specificFiles=TRUE
  if [[ -z $SPECIFIC_LIB ]]; then
    #Default lib used
    LIB_FIRST=1
    LIB_LAST=1
  else
    #Provided lib used
    LIB_FIRST=$SPECIFIC_LIB
    LIB_LAST=$SPECIFIC_LIB
  fi
else
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
fi
##Should check if libraries exit

if [[ -z "${IGNORE_GENOME}" ]]; then 
  IGNORE_GENOME="FALSE"
fi

if [[ ! -z "$step" ]]; then
  if [[ "$step" -gt 5 || "$step" -lt 1 ]]; then
     >&2 echo -e "${red}==> Terminating${NC} - That step doen't exist please specify a lower step"         
     exit 127
  fi
fi
#Test if the var step exists
if [[ -z "$step" ]]; then 
  step=0
fi


#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#Get config settings
. $DIR/"config/workdirs.cfg"
SOFT_CFG=${DIR}"/config/software_dirs.cfg"
. $SOFT_CFG


if [[ -z $HEADLESS_MODE && $HEADLESS == "FALSE" ]]; then
  if ! xset q &>/dev/null; then
      echo -e "No X server at \$DISPLAY [$DISPLAY] - ${blue}You are probably running on a server${NC}, but didn't set the ${red}headless mode${NC}. \nCheck if the necessary dependencies are installed: https://mirpursuit.readthedocs.io/en/latest/install.html#for-headless-server-no-x-server-running" >&2
      exit 1
  fi
  ## TODO - Test if xvfb-run-safe is working 

fi


##Check for updates
if [[ "${GIT}" == "1" ]]; then
  if [[ "$(which git | wc -w)" -gt "1" ]];then
    ## "git not found" other then /usr/bin/git 
    $GIT == 0
    ##TODO set permanent
  else  
    echo -e "${blue}::This is a git install${NC}"
    cd ${DIR}
    #currentBranch=$(git branch --show-current)
    git remote update
    if [[ $(git status -u no | head -2 | tail -1) == "Your branch is up to date with 'origin/master'." ]];then
      echo -ne "Git repository up to date!\n\n\n"
    else
      git update-server-info
      current_commit=$(git rev-list --max-count=1 HEAD)
      >&2 echo -e "${red}==> Attention!${NC} There are pending updates to miRPursuit." 
      echo -e "${brown}List of pending commits (None if empty):${NC}\n"
      echo -e $(git rev-list ${current_commit}..origin/HEAD --oneline --graph)
      echo -ne "\n\n\n"
      unset $booleanYorN
      while [[ "$booleanYorN" != [yYnN] ]]
      do        
        read -n1 -p "Update? (Y/N)" booleanYorN
      done
      if [[ $booleanYorN == [nN] ]]; then
        echo -ne "\nContinuing without update"
      else
        >&2 echo -ne "\n\n\n\n\n\n\n\n\n\n${blue}Updating!${NC}"
        git pull origin master
        >&2 echo -ne "\n\n\r"
      fi      
    fi  
    cd -
  fi
else
  echo -ne "\n\t\t\t${red}This is not a GIT installation${NC}\n"
  if [[ "${GIT}" == "0" ]]; then
    echo "Update check disabled"
  else
    echo -ne "Install commit hash is ${green}${GIT}${NC}"
    echo "Currently not listing pending updates for non-git installations."
    echo "Consider changing this installation to a git clone repository."
    echo "Choose location and run command:"
    echo -e "${grey}  git clone https://github.com/forestbiotech-lab/miRPursuit.git${grey}"
    echo -ne "To get rid of this message change the value of ${grey}GIT${NC} var in ${green}[miRPursuit_dir]/conifg/software_dirs.ctg${NC} to ${green}0${NC} instead of the current hash there.\n\n\n\n\n\n\n\n"

  fi
fi

##Progress report starting and declaring variable
progress=${workdir}/PROGRESS

#Set this to use HEADLESS version
if [[ $HEADLESS_MODE == "TRUE" ]]; then
  sed -ri "s:(HEADLESS=)(.*):\1${HEADLESS_MODE}:" ${SOFT_CFG} 
fi
echo -ne "${blue}:: Checking install dependencies:${NC}\n"
#Check programs are set up and can run (Java and Wbench).
if [[ -z "$JAVA_DIR"  ]]; then
  echo -e "${red}==> Not set${NC}: Please set java var in ${blue}software_dirs.cfg${NC} config file or run install script"
  exit 127
else
  if [[ -x "$JAVA_DIR" && -e "${JAVA_DIR}" ]]; then
    echo -e "Java set up: ${green}OK${NC}"
  else
    echo -e "${red}==> Failed${NC}: Java can't be run or invalid path"
    exit 127
  fi        
fi

if [[ -z "$WBENCH_DIR" ]]; then
  echo -e "${red}==> Not set${NC}: Please set workbench var in ${blue}software_dirs.cfg${NC} config file or run install script"
  exit 127        
else        
  if [[ -x "$WBENCH_DIR" && -e "$WBENCH_DIR" ]]; then
    echo -e "Workbench set up ${green}OK${NC}"   
  else
    echo -e "${red}==> Failed${NC}: Workbench can't be run or invalid path. Please check the workbench var in the ${blue}software_dirs.cfg${NC} config file."
    exit 127
  fi
fi

echo -e "\n\n\n${blue}:: Running pipeline with the following arguments:${NC}"
#Only print if running in lib number mode
if [[ $specificFiles == "FALSE" ]]; then
  printf "First Library\t\t\t${brown}=${NC} ${green}${LIB_FIRST}${NC}\n"
  printf "Last Library\t\t\t${brown}=${NC} ${green}${LIB_LAST}${NC}\n"
  printf "${grey}Number of threads\t\t${brown}=${NC} ${green}${THREADS}${NC}\n"
fi

if [[ -e "${DIR}/config/filters/wbench_filter_${FILTER_SUF}.cfg" ]]; then
  echo -e "Filter suffix               ${brown}=${NC} ${green}${FILTER_SUF}${NC}"
  cp ${DIR}/config/filters/wbench_filter_${FILTER_SUF}.cfg ${DIR}/config/wbench_filter_in_use.cfg
else
  >&2 echo -e "${red}==> Error${NC} - The given filter file doesn't exist please check the file exists. Correct the FILTER_SUF var in ${blue}workdirs.cfg${NC} config file."  
  exit 127
fi
if [[ -e "${GENOME}" ]]; then        
  echo -e "${grey}Genome                      ${brown}=${NC} ${green}${GENOME}${NC}"
else
  >&2 echo -e "${red}==> Error${NC} - The given genome file doesn't exist please check the file exists. Correct the GENOME var in ${blue}workdirs.cfg${NC} config file."
  exit 127
fi
if [[ -e "${GENOME_MIRCAT}" ]]; then        
  echo -e "${grey}Genome mircat               ${brown}=${NC} ${green}${GENOME_MIRCAT}${NC}"
else
  echo -e "${red}==> Error${NC} - The given genome file for mircat doesn't exit please check the file exists. Correct the GENOME_MIRCAT var in ${blue}workdirs.cfg${NC} config file."
fi
if [[ -e "${MIRBASE}" ]]; then        
  echo -e "${grey}miRBase                     ${brown}=${NC} ${green}${MIRBASE}${NC}"
else
  echo -e "${red}==> Error${NC} - The given miRBase file doesn't exist please check the file exists. Correct the MIRBASE var in ${blue}workdirs.cfg${NC} config file."
  exit 127
fi
if [[ -z "${workdir}" ]]; then
  echo -e "${red}==> Not set:${NC} No workdir hasn't been set please don't put a trailing /, see config workdirs.cfg."
  exit 127
else
  echo -e "${grey}Working directory (workdir) ${brown}=${NC} ${green}${workdir}${NC}"      
fi

##############STEP 0 ##############################################################
if [[ -d "${INSERTS_DIR}" && "${step}" == "0" ]]; then
  echo -e "${grey}sRNA directory (INSERTS_DIR)${brown}=${NC} ${green}${INSERTS_DIR}${NC}"
  #Not dealing files from multiple files with same pattern but different extensions
  #Checking if any thing matches first then it will check if multiple files are being found in pipe_fast*
  
  if [[ ! -z "$fasta" && $specificFiles == "FALSE" ]]; then  
    if [[ -f ${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${fasta}0*${LIB_FIRST}[^0-9].*(fa|fasta)+(\.gz)*$")  ]]; then
      testLib=$(ls ${INSERTS_DIR} | grep -E ".*${fasta}0*${LIB_FIRST}[^0-9].*(fa|fasta)+(\.gz)*$")     
    else
      testLib="${red}NOT FOUND${NC}"
    fi
  fi
  if [[ ! -z "$fasta" && $specificFiles == "TRUE" ]]; then
      testLib=$(basename $fasta)
  fi
  if [[ ! -z "$fastq" && $specificFiles == "FALSE" ]]; then
    if [[ -f ${INSERTS_DIR}/$(ls ${INSERTS_DIR} | grep -E ".*${fastq}0*${LIB_FIRST}[^0-9].*(fq|fastq)+(\.gz)*$") ]];then
      testLib=$(ls ${INSERTS_DIR} | grep -E ".*${fastq}0*${LIB_FIRST}[^0-9].*(fq|fastq)+(\.gz)*$")    
    else
      testLib="${red}NOT FOUND${NC}"
    fi
  fi
  if [[ ! -z "$fastq" && $specificFiles == "TRUE" ]]; then
      testLib=$(basename $fastq)
  fi
  ###DEPRECATED WILL SOON BE REMOVED  
  if [[ ! -z "$LC" ]]; then  
    testLib=$(echo ${INSERTS_DIR}/*${fasta}${fastq}${LC}${LIB_FIRST}*)
  fi
  if [[ ! -z "$testLib" ]]; then
    echo -e "\n${grey}First lib to be processed   ${brown}=${NC} ${green}${testLib}${NC}"
    if [[ ${testLib} == "\e[0;31mNOT FOUND\e[0m" ]];then 
      echo -e "${red}==> Common string${NC}: The string used to group the sRNAs hasn't produced a proper result, see ${blue}https://mirpursuit.readthedocs.io/en/latest/gettingstarted.html#how-to-run-the-program${NC} ."
      exit 127
    fi
  else
    >&2 echo -e "${red}==> Invalid pattern:${NC} - No file / multiple files found, in inserts dir that matches your input settings ${green}${fasta}${fastq}${LC}${NC} for lib ${LIB_FIRST}. Or perhaps you're starting lib ${LIB_FIRST} is to low."
    exit 127
  fi      
else
  if [[ -d "${INSERTS_DIR}" ]]; then
    echo -e "${grey}sRNA directory (INSERTS_DIR)${brown}=${NC} ${green}${INSERTS_DIR}${NC}"
  else        
    echo -e "${red}==> Invalid dir${NC}: The inserts directory hasn't been configured properly, see config file ${blue}workdirs.cfg${NC}."
    exit 127
  fi  
fi

#nonempty string bigger than 0 (Can't remember purpose of this!)
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi
if [[ -d "$workdir" && "${noPrompt}" == "FALSE" ]]; then
  unset $booleanYorN
  >&2 echo -e "\n\n${red}==> Attention!${NC}\nworkdir ${brown}=>${NC} ${green}$workdir${NC} \nData already that exists in this folder might be overwritten." 
  while [[ "$booleanYorN" != [yYnN] ]]
  do        
    read -n1 -p "Continue? (Y/N)" booleanYorN
  done
  if [[ $booleanYorN == [nN] ]]; then
    echo $(date +"%y|%m|%d-%H:%M:%S")" - Terminated prematurely due to possibility of workdir being overwritten."
    >&2 printf "\nTerminating prematurely\n"
    exit 1
  else
    >&2 echo -ne "\n\n\r"
  fi
fi
mkdir -p $workdir"/log/"
printf "0\tStarted\t0" >$progress
runDate=$(date +"%y|%m|%d-%H:%M:%S")
log_file="${workdir}/log/${runDate}:$$:Global:${LIB_FIRST}-${LIB_LAST}.log"


#Make dir to store all logs generated by subscripts.
mkdir -p $workdir"/log/$runDate"
exec >&1 > ${log_file}
echo $(date +"%y/%m/%d-%H:%M:%S")" - "$(basename ${log_file})
printf "\nRan with these vars:\n###################\n#software_dirs.cfg#\n###################\n"
cat $SOFT_CFG
printf "\nRan with these vars:\n##############\n#workdirs.cfg#\n##############\n"
cat $DIR/"config/workdirs.cfg"
printf "\n\n"

SCRIPTS_DIR=$DIR"/scripts"

if [[ ! -z "$LC" ]]; then
  >&2 echo -e "${purple}==> Running in LC mode.${NC}"
  ${DIR}/extract_lcscience_inserts.sh $LIB_FIRST $LIB_LAST $LC
  step=1
fi
if [[ ! -z "$fastq" ]]; then
  >&2 echo -e "${purple}==> Running in fastq mode.${NC} - Copying fastq files..."
  if [[ $specificFiles == "TRUE" ]]; then
    ########## Convert to absolute path? #################
    ${DIR}/pipe_fastq.sh $LIB_FIRST $fastq
  else
    ${DIR}/pipe_fastq.sh $LIB_FIRST $LIB_LAST $fastq
  fi
  step=1
fi
if [[ ! -z "$fasta" ]]; then
  >&2 echo -e "${purple}==> Running in fasta mode.${NC} - Copying fasta files..."
  if [[ $specificFiles == "TRUE" ]]; then
    ########## Convert to absolute path? #################
    ${DIR}/pipe_fasta.sh $LIB_FIRST $fasta
  else
    ${DIR}/pipe_fasta.sh $LIB_FIRST $LIB_LAST $fasta
  fi  
  ##Make profile
  step=1
fi

if [[ "$step" -eq 0 ]]; then        
  #Concatenate and convert to fasta
  >&2 echo -ne "${blue}:::: Step 0${NC} - Concatenating libs and converting to fasta [                         ]  0%\r"
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
      >&2 echo -ne "${blue}:::: Step 1${NC} - Adaptor removal                            [##                       ] 10%\r"  
      printf "10\tAdaptor\t1" >$progress

      ${DIR}/pipe_trim_adaptors.sh $LIB_FIRST $LIB_LAST
    fi
  else
    if [[ ! -z "$fastq" ]]; then
      echo -e "${red}Attention!${NC}: - Not performing adaptor trimming"
    fi
  fi
  #Filter size, t/rRNA, abundance.
  >&2 echo -ne "${blue}:::: Step 1${NC} - Filtering libs with workbench Filter      [#####                    ] 20%\r"
  printf "20\tFiltering\t1" >$progress

  ${DIR}/pipe_filter_wbench.sh $LIB_FIRST $LIB_LAST
  step=2
fi
if [[ "$step" -eq 2 ]]; then 
  #Filter genome and mirbase
  >&2 echo -ne "${blue}:::: Step 2${NC} - Filtering libs against genome and mirbase  [##########               ] 40%\r"
  printf "40\tGenome miRBase\t2" >$progress

  ${DIR}/pipe_filter_genome_mirbase.sh $LIB_FIRST $LIB_LAST ${IGNORE_GENOME}
  step=3
fi
if [[ "$step" -eq 3 ]]; then 
  #tasiRNA
  >&2 echo -ne "${blue}:::: Step 3${NC} - Running tasi, searching for tasi reads     [###############          ] 60%\r"
  printf "60\tTasi\t3" >$progress
  ${DIR}/pipe_tasi.sh $LIB_FIRST $LIB_LAST 
  step=4
fi
if [[ "$step" -eq 4 ]]; then 
  #mircat
  >&2 echo -ne "${blue}:::: Step 4${NC} - Running miRCat (Be patient, slow step)     [####################     ] 80%\r"
  printf "80\tmiRCat\t4" >$progress

  ${DIR}/pipe_mircat.sh $LIB_FIRST $LIB_LAST
  step=5
fi  
if [[ "$step" -eq 5 ]]; then
  >&2 echo -ne "${blue} Step 5${NC} - Counting sequences to produces matrix          [######################   ] 90%\r"
  printf "90\tCounting\t5" >$progress
  ${DIR}/counts_merge.sh 
  >&2 echo -ne "${blue}:::: Step 5${NC} - Running report                             [######################## ] 95%\r"
  printf "95\tReporting\t5" >$progress
  $SCRIPTS_DIR/report.sh $LIB_FIRST $LIB_LAST ${DIR}
  ${DIR}/write_report.sh $LIB_FIRST $LIB_LAST complete
fi

  >&2 echo -e "${blue}:::: Step 5${NC} - Done, files are in workdir                 [#########################] 100%"
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
mv ${workdir}/log/*PPID$$*.log ${workdir}/log/$runDate

echo $(basename $ok_log)
duration=$(date -u -d @${SECONDS} +"%T")
printf "\n-----------END--------------\nmiRPursuit ran in ${SECONDS}secs\nmiRPursuit ran in ${duration}\n"
>&2 echo -e "${green}Finished${NC} - sRNA-workflow finished successfully. Runtime: ${duration}"
mv $log_file $ok_log

RUN=$(( $RUN + 1 ))
sed -ri "s:(RUN=)(.*):\1${RUN}:" ${SOFT_CFG}

exit 0
