#!/usr/bin/env bash

# install.sh
# 
#
# Created by Bruno Costa on 28/09/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# 
# Call: install.sh

echo "Checking avalible software"

##Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

##get software dirs
. ${DIR}/config/software_dirs.cfg

if [[ -z "$SOFTWARE" ]]; then
  SOFTWARE="${HOME}/.software"
  mkdir -p $SOFTWARE
  sed -r "s:(SOFTWARE=)(.*):\1${HOME}/.software:" > temp_12345678987654321
  mv temp_12345678987654321 ${DIR}/config/software_dirs.cfg
  rm temp_12345678987654321    
fi
echo $SOFTWARE
echo "Software"
command -v tar >/dev/null 2>&1 || { echo >&2 "Tar is required before starting. sudo apt-get install tar if you have administrative access or ask your sysadmin to install it."; }

for i in patman java fastq_to_fasta
do
  eval $i="FALSE"
  command -v $i >/dev/null 2>&1 || { echo >&2 "$i required. Installing";eval $i="TRUE"; }
done

#Patman installation
if [[ "$patman" == "TRUE" ]]; then
  echo $patman
  echo "Patman"
  cd $SOFTWARE
  patman_url=https://bioinf.eva.mpg.de/patman/patman-1.2.2.tar.gz
  echo "Starting to download patman"
  wget -c $patman_url
  echo "Extracting data..."
  tar -xzvf patman-1.2.2.tar.gz
  cd patman-1.2.2
  echo "patman has been add to you path in ~/.profile if necessary add it to a more convinent location or change binaries to a directory in your path"
  echo "##Added patman to path" >> ${HOME}/.profile
  echo "PATH=\$PATH:${SOFTWARE}/patman-1.2.2/" >> ${HOME}/.profile
  export PATH=${PATHi}:${SOFTWARE}/patman-1.2.2/
  patman -V	
  cd -
fi

#Java installation
if [[ "$java" == "TRUE" ]]; then
  echo $java
  echo "JAVA"
  echo "Downloading Java"
  java_url=http://javadl.sun.com/webapps/download/AutoDL?BundleId=109700
  wget -c java_url
  tar xzvf AutoDL?BundleId=109700
  echo "Added Java to software.cfg"	
  sed -r "s:(JAVA_DIR=)(.*):\1${SOFTWARE}/jre1.8.0_60/bin:" > temp_12345678987654321
  mv temp_12345678987654321 ${DIR}/config/software_dirs.cfg
  rm temp_12345678987654321

fi

#Fastx_toolkit installation
if [[ "$fastq_to_fasta" == "TRUE"  ]]; then
  echo $fastq_to_fasta
  echo "Fastx_toolkit"
  fastx_toolkit_url=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
  cd ${SOFTWARE}
  echo "Starting to download fastx_toolkit"
  wget -c $fastx_toolkit_url
  echo "Extracting data..."
  tar -jxvf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
  echo "Fastx_toolkit has been add to you path in ~/.profile if necessary add it to a more convinent location or change binaries to a directory in your path"
  echo "##Added Fastx_toolkit binaries to path" >> ${HOME}/.profile
  echo "PATH=\$PATH:${SOFTWARE}/bin/" >> ${HOME}/.profile
  export PATH=${PATHi}:${SOFTWARE}/bin/
  cd -
fi
#UEA sRNA workbench  || Get creative....

if [[ -z "$WBENCH_DIR" ]]; then
  workbench_url=http://downloads.sourceforge.net/project/srnaworkbench/Version4/srna-workbenchV4.0Alpha.zip
  cd ${SOFTWARE}
  echo "Starting to download UEA sRNA Workbench"
  wget -c $workbench_url
  unzip srna-workbenchV4.0Alpha.zip
  sed -r "s:(WBENCH_DIR=)(.*):\1${SOFTWARE}/srna-workbenchV4.0Alpha:" > temp_12345678987654321
  mv temp_12345678987654321 ${DIR}/config/software_dirs.cfg
  rm temp_12345678987654321	
  cd -
fi



##activate new .profile
source ~/.profile



