#!/usr/bin/env bash

# install.sh
# 
#
# Created by Bruno Costa on 28/09/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# 
# Call: install.sh


# OUTPUT-COLORING
red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color


echo "Run as ./install.sh or it will produce errors"
echo "Checking avalible software"

##Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CFG=${DIR}/config/software_dirs.cfg
CFG_WD=${DIR}/config/workdirs.cfg
CFG_mircat=${DIR}/config/wbench_mircat.cfg


##get software dirs
. $CFG

if [[ -z "$SOFTWARE" ]]; then
  SOFTWARE="${HOME}/.Software"
  sed -r "s:(SOFTWARE=)(.*):\1${HOME}/.software:" ${CFG}  > temp_12345678987654321
  mv temp_12345678987654321 ${CFG}
fi

##Source_data directory
SOURCE_DATA=${HOME}/source_data

#Create if necessary software dir
mkdir -p $SOFTWARE

echo $SOFTWARE
echo "Software"
command -v tar >/dev/null 2>&1 || { echo >&2 "Tar is required before starting. sudo apt-get install tar if you have administrative access or ask your sysadmin to install it."; }

for i in patman fastq_to_fasta
do
  eval $i="FALSE"
  command -v $i >/dev/null 2>&1 || { echo >&2 "$i required. Installing";eval $i="TRUE"; }
done

#Patman installation
if [[ "$patman" == "TRUE" ]]; then
  echo $patman
  echo "Patman installation"
  cd $SOFTWARE
  patman_url="https://bioinf.eva.mpg.de/patman/patman-1.2.2.tar.gz"
  echo "Starting to download patman"
  wget -c $patman_url
  echo "Extracting data..."
  PATMAN_BASENAME=$(basename $patman_url)
  PATMAN_ROOT=${patman_url%.tar.gz}
  tar -xzvf $PATMAN_BASENAME
  cd "patman-1.2.2"
  echo "patman has been add to you path in ~/.profile if necessary add it to a more convinent location or change binaries to a directory in your path"
  echo "##Added patman to path" >> ${HOME}/.profile
  echo "PATH=\$PATH:${SOFTWARE}/patman-1.2.2/" >> ${HOME}/.profile
  export PATH=${PATH}:${SOFTWARE}"/patman-1.2.2/"
  patman -V	
  cd -
fi

#Java installation
if [[ -z "$JAVA_DIR" ]]; then
  echo $java
  cd $SOFTWARE
  echo "JAVA installation"
  echo "Downloading Java"
  java_url="http://javadl.sun.com/webapps/download/AutoDL?BundleId=109700"
  wget -c $java_url
  tar -xzvf "AutoDL?BundleId=109700"
  echo "Added Java to software.cfg"	
  sed -r "s:(JAVA_DIR=)(.*):\1${SOFTWARE}/jre1.8.0_60/bin:" ${CFG}  > temp_12345678987654321
  mv temp_12345678987654321 ${CFG}
  #preform test to ensure installed sucessfully
  echo "Java installed - Java added to software_dirs.cfg"
fi

#Fastx_toolkit installation
if [[ "$fastq_to_fasta" == "TRUE"  ]]; then
  echo $fastq_to_fasta
  echo "Fastx_toolkit installation"
  fastx_toolkit_url="http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2"
  cd ${SOFTWARE}
  echo "Starting to download fastx_toolkit"
  wget -c $fastx_toolkit_url
  echo "Extracting data..."
  tar -jxvf "fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2"
  echo "Fastx_toolkit has been add to you path in ~/.profile if necessary add it to a more convinent location or change binaries to a directory in your path"
  echo "##Added Fastx_toolkit binaries to path" >> ${HOME}/.profile
  echo "PATH=\$PATH:${SOFTWARE}/bin/" >> ${HOME}/.profile
  export PATH=${PATH}:${SOFTWARE}"/bin/"
  cd -
fi
#UEA sRNA workbench  || Get creative....

if [[ -z "$WBENCH_DIR" ]]; then
  workbench_url="http://downloads.sourceforge.net/project/srnaworkbench/Version3Alpha/srna-workbenchV3.01_ALPHA.zip?r=http%3A%2F%2Fsrna-workbench.cmp.uea.ac.uk%2Fthe-uea-small-rna-workbench-version-3-01-alpha%2F&ts=1452081706&use_mirror=heanet"
  cd ${SOFTWARE}
  echo "Starting to download UEA sRNA Workbench"
  wbench_filename=srna-workbenchV3.01_ALPHA.zip
  wget -c $workbench_url -O $wbench_filename 
  unzip $wbench_filename
  sed -r "s:(WBENCH_DIR=)(.*):\1${SOFTWARE}/${wbench_filename}:" ${CFG} > temp_12345678987654321
  mv temp_12345678987654321 ${CFG}
  cd -
fi



##activate new .profile
source ~/.profile

echo -e "${green}Installation completed...${NC} However please check patman is in your path if not please restart your terminal"

echo "Configuring the workdir parameters."


while [[ "$booleanYorN" != [yYnN] ]]
do        
	read -n1 -p "Create source data folder (Where genomes and other stuff will be) in: ${SOURCE_DATA} ? (Y/N)" booleanYorN
	case $boolreanYorN in
	  y|Y) echo "Creating folder";mkdir -p ${SOURCE_DATA};;
	  n|N) echo "";;
	  *) echo "Prompt ignored, creating folder";;
	esac
done

if [[ $booleanYorN == [nN]  ]]; then
read -p "Please enter the full path where source_data should be created " SOURCE_DATA
 mkdir -p $SOURCE_DATA  
fi
unset booleanYorN 


while [[ "$booleanYorN" != [yYnN] ]]
do        
  read -n1 -p  "Do you wish to download the latest version of mirbase? (Y/N)" booleanYorN
  case $booleanYorN in 
    y|Y) echo -e "\nDownloading mirbase";;
    n|N) echo "Skipped mirbase installtion please set up this value in config file";;
    *)  echo "Invalid Input ";;
  esac  
done
if [[ "$booleanYorN" == [yY] ]]; then 
  mirbase=${SOURCE_DATA}/mirbase      
  mkdir -p $mirbase
  cd $mirbase
  mirbase_mature="ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz"
  mirbase_readme="ftp://mirbase.org/pub/mirbase/CURRENT/README"
  mirbase_filename=$(basename $mirbase_mature)
  wget -c $mirbase_mature -O $mirbase_filename
  wget -c $mirbase_readme -O README
  if [[ -e $mirbase_filename ]]; then 
    gunzip $mirbase_filename
    sed -ri "s:(MIRBASE=)(.*):\1${SOURCE_DATA}/mirbase:" ${CFG_WD} 
  else
    echo -e "${red}Warning - Failed to download mirbase but script will continue.${NC}"
  fi

fi
unset booleanYorN


echo "Please insert the full path to the genome file (To maintain stuff organized we suggest:"
read -p "	<<souce_data-dir>>/genome/<<genome_name>>.fa) " GENOME
sed -ri "s:(GENOME=)(.*):\1${GENOME}:" ${CFG_WD}


SET_PROC=$(( $(nproc) - 1 ))

while [[ "$booleanYorN" != [yYnN] ]]
do        
	read -n1 -p "Setting number of threads to ${SET_PROC} (Y/N)" booleanYorN
	case $booleanYorN in
	  y|Y) echo "Processor number set to ${SET_PROC}";;
	  n|N) echo "";;
	  *)echo "Invalid input";;
	esac
done
if [[ "$booleanYorN"  == [yY] ]]; then 
  sed -ri "s:(THREADS=)(.*):\1${SET_PROC}:" ${CFG_WD} 
  sed -ri "s:(Thread_Count=)(.*):\1${SET_PROC}:" ${CFG_mircat}
fi
if [[ "$booleanYorN" == [nN] ]]; then
  read -p "Please specify the maximum amount of cores to be used " N_COREs
  sed -ri "s:(THREADS=)(.*):\1${N_COREs}:" ${CFG_WD}
  sed -ri "s:(Thread_Count=)(.*):\1${N_COREs}:" ${CFG_mircat}

fi 
unset booleanYorN


TOTAL_MEM=$(free -g | grep Mem: | awk '{print $2}')
SET_MEM=$(( $TOTAL_MEM - 2 ))

while [[ "$booleanYorN" != [yYnN] ]]
do        
	read -n1 -p "You have ${TOTAL_MEM}Gb of RAM. Maximum RAM will be set to ${SET_MEM}Gb. (Y/N)" booleanYorN
	case $booleanYorN in
	  y|Y) echo "Setting to ${SET_MEM}g";;
	  n|N) echo "" ;;
	  *) echo "Invalid input";;
	esac
done
if [[ "$booleanYorN"  == [nN] ]]; then
  read -p "Please specify the amount of maximum RAM to be used by pipeline in Gigabytes (Numbers only) " memory
  sed -ri "s:(MEMORY=)(.*):\1\"${memory}g\":" ${CFG_WD}
fi
if [[ "$booleanYorN" == [yY] ]]; then
  sed -ri "s:(MEMORY=)(.*):\1\"${SET_MEM}g\":" ${CFG_WD}
fi
echo "What is the full path to the directory where your sRNA libraries are inserts_dir"
read -p "	(Please work with backuped files) " inserts_dir
  sed -ri "s:(INSERTS_DIR=)(.*):\1${inserts_dir}:" ${CFG_WD}

echo -e "\nYour current settings are:"
echo $(cat ${CFG_WD})
echo -e "${green}Installation finished${NC}"

exit 0
