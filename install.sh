#!/bin/sh

# install.sh
# 
#
# Created by Bruno Costa on 28/09/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# 
# Call: install.sh

echo "Checking avalible software"

#Gets the scipt directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#get software dirs
. ${DIR}/config/software_dirs.cfg

if [[ -z "$SOFTWARE" ]]; then
  $SOFTWARE=$HOME/.software
  mkdir -p $SOFTWARE  
fi

command -v tar >/dev/null 2>&1 || { echo >&2 "Tar is required before starting. sudo apt-get install tar if you have administrative access or ask your sysadmin to install it."; }

for i in patman shit
do
  command -v $i >/dev/null 2>&1 || { echo >&2 "$i required. Installing"; }
done

#Patman installation
if [[   -eq "TRUE" ]]; then
 patman_url=https://bioinf.eva.mpg.de/patman/patman-1.2.2.tar.gz
fi

#Java installation
if [[   -eq "TRUE" ]]; then
  java_url=http://javadl.sun.com/webapps/download/AutoDL?BundleId=109700
fi

#Fastx_toolkit installation
if [[ $fastx_tk -eq "TRUE"  ]]; then
  fastx_toolkit_url=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
fi

#UEA sRNA workbench
workbench_url=https://sourceforge.net/projects/srnaworkbench/files/latest/download?source=navbar
url2=http://downloads.sourceforge.net/project/srnaworkbench/Version4/srna-workbenchV4.0Alpha.zip?r=http%3A%2F%2Fsrna-workbench.cmp.uea.ac.uk%2Fdownloadspage%2F&ts=1443482124&use_mirror=netix



