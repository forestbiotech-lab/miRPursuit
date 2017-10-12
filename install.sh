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
blue='\e[0;34m'
green='\e[0;32m'
blink='\e[5m'
unblink='\e[25m'
invert='\e[7m'
NC='\e[0m' # No Color

#dependencies (Problems caused by UEA sRNA workbench)
#libgtk2.0-0
#libXtst6
#libxxf86vm1
#etc.. 
#Must install openjdk-8-jdk because of UEA sRNA workbench.
#Then it on remote server o my have to connect with x11 enabled ex: ssh -Y username@server
#Then run:: java -jar pathtoWorkbench/workbench.java -tool filter
#And accept their terms and conditions.
# install xvfb
# then Xvfb :1 &
# export DISPLAY=:1
# 


echo "Run as ./install.sh or it will produce errors"
echo "Checking available software"

##Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CFG=${DIR}/config/software_dirs.cfg
CFG_WD=${DIR}/config/workdirs.cfg
CFG_mircat=${DIR}/config/wbench_mircat.cfg

#URLS LIST
fastQC_url="http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip"
patman_url="https://bioinf.eva.mpg.de/patman/patman-1.2.2.tar.gz"
java_url="http://javadl.sun.com/webapps/download/AutoDL?BundleId=109700"
workbench_url="http://downloads.sourceforge.net/project/srnaworkbench/Version4/srna-workbenchV4.0Alpha.zip?r=http%3A%2F%2Fsrna-workbench.cmp.uea.ac.uk%2Fdownloadspage%2F&ts=1454556621&use_mirror=netcologne"
fastx_toolkit_url="http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2"


##Snippet for getting current shell startup file
##Working for bash an zsh, not tested for the others
shell=$(basename $SHELL)

profile=$HOME/.profile

case $shell in
  bash)
    profile=$HOME/.bashrc
  shift
  ;;
  zsh)
    profile=$HOME/.zshrc
  shift
  ;;
  fish)
    profile=$HOME/.config/fish/config.fish
  shift
  ;;
  ksh)
      profile=$HOME/.profile
    shift
  ;;
  tcsh)
    profile=$HOME/.login  
esac
shift

#Ensure that the file exists
touch $profile

##get software dirs
. $CFG

if [[ -z "$SOFTWARE" ]]; then
  SOFTWARE="${HOME}/.Software"
  sed -r "s:(SOFTWARE=)(.*):\1${SOFTWARE}:" ${CFG}  > temp_12345678987654321
  mv temp_12345678987654321 ${CFG}
fi

##Git installation?
cd $DIR 
if [[ $(git rev-parse --verify HEAD) ]]; then 
  sed -ri "s:(GIT=)(.*):\11:" ${CFG}
else 
  echo -e "${red} Warning!${NC} - This is not git clone installation updating will be difficult."
  echo "Installation will continue but consider installing with:"
  echo "   git clone https://github.com/forestbiotech-lab/miRPrusuit"
  installJSON=".install_time_stateOFart.json"
  curl https://api.github.com/repos/forestbiotech-lab/miRPursuit/commits > $installJSON
  commit_SHA=$(grep -m1 sha $installJSON | sed -r "s:[\" ,]::g" | awk -F ":" '{print $2}')
  sed -ri "s:(GIT=)(.*):\1${commit_sha}:" ${CFG}
  sleep 5
fi

cd -
##Source_data directory
SOURCE_DATA=${HOME}/source_data

#Create if necessary software dir
mkdir -p $SOFTWARE

echo $SOFTWARE
echo "Software"
command -v tar >/dev/null 2>&1 || { echo >&2 "Tar is required before starting. sudo apt-get install tar if you have administrative access or ask your sysadmin to install it."; }

for i in patman fastq_to_fasta fastqc unzip java
do
  eval $i="FALSE"
  command -v $i >/dev/null 2>&1 || { echo >&2 "$i required. Installing";eval $i="TRUE"; }
done

if [[ "$unzip" == "TRUE" ]]; then
  >&2 echo -e "${red} Warning!${NC} - unzip needed. Can not continue without this tool." 
  >&2 echo -e "${red} Warning!${NC} - Ask your administrator to install unzip." 
  >&2 echo -e "${red} Warning!${NC} - If you have administrator access run: sudo apt-get install unzip." 
  >&2 echo -e "${red} Warning!${NC} - Or download unzip and add it to your path."
  >&2 echo -e "${red} Warning!${NC} - Help on installation here: http://www.linuxfromscratch.org/blfs/view/svn/general/unzip.html " 
  >&2 echo -e "${red} Warning!${NC} - Please run this again once unzip is installed."
  exit 1
fi

#PatMaN installation
if [[ "$patman" == "TRUE" ]]; then
  echo $patman
  echo "PatMaN installation"
  cd $SOFTWARE
  echo "Starting to download patman"
  wget -c $patman_url
  echo "Extracting data..."
  PATMAN_BASENAME=$(basename $patman_url)
  PATMAN_ROOT=${patman_url%.tar.gz}
  tar -xzvf $PATMAN_BASENAME
  cd "patman-1.2.2"
  #Check if file exists to append to it
  if [[ -e $profile ]]; then
    echo "patman has been add to you path in $profile if necessary add it to a more convinent location or change binaries to a directory in your path"
    echo "##Added patman to path" >> $profile
    echo "PATH=\$PATH:${SOFTWARE}/patman-1.2.2/" >> $profile
    echo "appended to ${profile}"
    echo -e "${green}PatMaN installation finished${NC} - PatMaN added to PATH"
    sleep 1
    echo ""
  else
    echo -e "${red}Warning!${NC} - Could not add PatMaN to path."
    echo "File doesn't exist - $profile.  "
    sleep 1
    echo "Add the following line to your startup shell file ex: .bashrc, .bash_profile, etc."
    echo "PATH=\$PATH:${SOFTWARE}/patman-1.2.2/"  
    echo ""
  fi
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
  wget -c $java_url
  tar -xzvf "AutoDL?BundleId=109700"
  echo "Added Java to software.cfg" 
  sed -ri "s:(JAVA_DIR=)(.*):\1${SOFTWARE}/jre1.8.0_60/bin:" ${CFG}
  #preform test to ensure installed successfully
  echo -e "${green}Java installed$NC - Java added to software_dirs.cfg"
  sleep 1
  if [[ "${java}" == "TRUE" ]]; then
    echo "No other version of java was installed. Java will be added to your path in profile"
    if [[ -e $profile ]]; then
      echo "Java has been add to you path in ${profile} if necessary add it to a more convinent location or change binaries to a directory in your path"
      echo "##Added java to path" >> $profile
      echo "PATH=\$PATH:${SOFTWARE}/jre1.8.0_60/bin/" >> $profile
      echo "Java appended to ${profile}"
      echo -e "${green}Java installation finished${NC} - Java added to PATH"
      sleep 1
      echo ""
    else
      echo -e "${red}Warning!${NC} - Could not add Java to path."
      echo "File doesn't exist - $profile.  "
      sleep 1
      echo "Add the following line to your startup shell file ex: .bashrc, .bash_profile, etc."
      echo "PATH=\$PATH:${SOFTWARE}/jre1.8.0_60/bin/"  
    fi    
  echo "If you want to use a different flavour of java just remove it from it's path. Inclusion in path is just for fastqc."
  fi
fi

#Fastx_toolkit installation
if [[ "$fastq_to_fasta" == "TRUE"  ]]; then
  echo "Fastx_toolkit installation"
  cd ${SOFTWARE}
  echo "Starting to download fastx_toolkit"
  wget -c $fastx_toolkit_url
  echo "Extracting data..."
  tar -jxvf "fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2"
  #Check if file exists to append to it
  if [[ -e $profile ]]; then
    echo "appended to ${profile}"
    echo "Fastx_toolkit has been added to you path in ~/.profile if necessary add it to a more convenient location or change binaries to a directory in your path"
    echo "##Added Fastx_toolkit binaries to path" >> $profile
    echo "PATH=\$PATH:${SOFTWARE}/bin/" >> $profile
    echo -e "${green} Fastx_toolkit installation finished $NC"
    echo ""
    sleep 1
  else
    echo -e "${red}Warning!${NC} - Could not add Fastx_toolkit to path."
    echo "File doesn't exist - $profile.  "
    echo "Add the following line to your startup shell file ex: .bashrc, .bash_profile, etc."
    echo "PATH=\$PATH:${SOFTWARE}/bin/"
    echo ""
    sleep 1
  fi
  export PATH=${PATH}:${SOFTWARE}"/bin/"
  cd -
fi

#Fastx_toolkit installation
if [[ "$fastqc" == "TRUE"  ]]; then
  echo "fastQC installation"
  cd ${SOFTWARE}
  echo "Starting to download fastx_toolkit"
  wget -c $fastQC_url
  echo "Extracting data..."
  unzip "fastqc_v0.11.5.zip"
  ## Set file as executable might require permission 
  chmod +x ${SOFTWARE}/FastQC/fastqc
  #Check if file exists to append to it
  if [[ -e $profile ]]; then
    echo "appended to ${profile}"
    echo "fastQC has been added to you path in ${profile} if necessary add it to a more convenient location or change binaries to a directory in your path"
    echo "##Added fastQC binaries to path" >> $profile
    echo "PATH=\$PATH:${SOFTWARE}/FastQC/" >> $profile
    echo -e "${green} Fastx_toolkit installation finished $NC"
    echo ""
    sleep 1
  else
    echo -e "${red}Warning!${NC} - Could not add fastQC to path."
    echo "File doesn't exist - ${profile}.  "
    echo "Add the following line to your startup shell file ex: .bashrc, .bash_profile, etc."
    echo "PATH=\$PATH:${SOFTWARE}/FastQC/"
    echo ""
    sleep 1
  fi
  export PATH=${PATH}:${SOFTWARE}"/FastQC/"
  cd -
fi



#UEA sRNA workbench  || Get creative....

if [[ -z "$WBENCH_DIR" ]]; then
  cd ${SOFTWARE}
  echo "Starting to download UEA sRNA Workbench"
  wbench_filename=srna-workbenchV4.0_ALPHA.zip
  wget -c $workbench_url -O $wbench_filename 
  unzip $wbench_filename
  wbench_folder=$(unzip -l ${SOFTWARE}/${wbench_filename} | grep "Workbench.jar" | awk '{print $4}'| awk -F "/" '{print $1}')
  sed -ri "s:(WBENCH_DIR=)(.*):\1${SOFTWARE}/${wbench_folder}:" ${CFG}
  echo -e "$green Workbench installation finished $NC"
  sleep 1
  echo ""
  cd -
fi


##activate new .profile
#source ${profile}
echo -ne "${green}Installation completed...${NC} However please check PatMaN is in your path if not please restart your terminal"
sleep 2
echo ""
echo -ne "${blue}Configuring the workdir parameters.${NC}\r"
#Just to make it more visually appealing let's set the illusion that something is happening here
sleep 1
echo -ne "${blue}Configuring the workdir parameters. .${NC}\r"
sleep 1
echo -ne "${blue}Configuring the workdir parameters. . .${NC}\r"
sleep 1
echo -ne "${blue}Configuring the workdir parameters. . . .${NC}"
sleep 1
echo ""

unset testingmode
testingMode="FALSE"
while [[ "$testingmode" != [yYnN] ]]
do
	read -n1 -p "Whould you like to configure miRPursuit to run the test dataset [Y]es [N]o?" testingmode
	case $testingmode in
		y|Y)     echo -ne "\e[2K\rInstallation will configure for test dataset\n";testingMode="TRUE";;
	  	n|N)     echo -ne "\e[2K\rInstallation Will setup based on your input\n";;
		[^yYnN]) echo -ne "\e[2K\rInvalid input please type either (Y/N)\n";;
	esac
	
done

while [[ "$booleanYorN" != [yYnN] ]]
do        
	read -n1 -p "Create source data folder (Where genomic resources, such as genomes, miRBase, etc...) in: ${SOURCE_DATA}? [Y]es [N]o" booleanYorN
	case $booleanYorN in
	  y|Y) echo -ne "\nCreating folder\n";mkdir -p ${SOURCE_DATA};;
	  n|N) echo -ne "\nUsing alternative path for source_data\n";;
	  [^yYnN]) echo -ne "\e[2K\rInvalid input please type either (Y/N)\n";;
	esac
done

if [[ $booleanYorN == [nN]  ]]; then
  read -p "Please enter the full path where source_data should be created" SOURCE_DATA
  read -n1 -p "Creating the path $SOURCE_DATA, are you sure? [Y]es [N]o" booleanYorN
  if [[ "$booleanYorN" == [Yy] ]];then
    mkdir -p $SOURCE_DATA"/source_data" && echo -ne "\nFolder created with sucess\n"
  else
    echo -ne "\nSkiping folder not created\n"
  fi      
fi
unset booleanYorN 


while [[ "$booleanYorN" != [yYnN] ]]
do        
  read -n1 -p  "Do you wish to download the latest version of miRBase? [Y]es [N]o)" booleanYorN
  case $booleanYorN in 
    y|Y) echo -ne "\nDownloading miRBase\n";;
    n|N) echo -ne "\nSkipped miRBase installation please set up this value in configuration file\n";;
    [^yYnN])  echo -ne "\e[2K\rInvalid Input please type either (Y/N)\n";;
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
    gunzip -c $mirbase_filename > ${mirbase_filename/.gz}
    sed -ri "s:(MIRBASE=)(.*):\1${SOURCE_DATA}/mirbase/${mirbase_filename/.gz/}:" ${CFG_WD} 
  else
    echo -e "${red}Warning - Failed to download miRBase but script will continue.${NC}"
  fi
else
  ## !!!!!!This should read the actual value stored	 
  read -n1 -p "The current miRBase directory in configuration file is $MIRBASE do you want to change it? (Y/N)" mirYorN
  case $mirYorN in
    y|Y)      echo -ne "\n Setting miRBase var.\n";;
    n|N)      echo -ne "\nValue not altered\n";;
    [^yYNn])  echo -ne"\nInvalid Input please type either (Y/N).\n";;
  esac
  if [[ "$mirYorN" == [yY] ]]; then
    read -p "Type new path for miRBase:" MIRBASE
    sed -ri "s:(MIRBASE=)(.*):\1${MIRBASE}:" ${CFG_WD} 
  fi
fi

unset booleanYorN

if [[ "$testingMode" == "TRUE" ]]; then
	TestGenome="Arabidopsis_thaliana.TAIR10.dna_rm.chromosome.4.fa"
	echo -ne "\n${green}Installing in test ready mode${NC}: Will setup for the test Genome: ${TestGenome}\n"
	mkdir -p ${SOURCE_DATA}/Genome
	ln -s ${DIR}/testDataset/Genome/${TestGenome} ${SOURCE_DATA}/Genome/${TestGenome} 
	sed -ri "s:(GENOME=)(.*):\1${SOURCE_DATA}/Genome/${TestGenome}:" ${CFG_WD}
	sed -ri "s:(GENOME_MIRCAT=)(.*):\1${SOURCE_DATA}/Genome/${TestGenome}:" ${CFG_WD}
	##Some more dramatic flare
	sleep 1
	echo -ne "${blue}Configuring the workdir parameters. .${NC}\r"
	sleep 1
	echo -ne "${blue}Configuring the workdir parameters. . .${NC}\r"
	sleep 1
	echo -ne "${blue}Configuring the workdir parameters. . . .${NC}"
	sleep 1
	echo ""
	
else
	echo "Please insert the full path to the genome file (To maintain stuff organized we suggest:"
	read -p "	<<souce_data-dir>>/Genome/<<genome_name>>.fa) " GENOME
	sed -ri "s:(GENOME=)(.*):\1${GENOME}:" ${CFG_WD}

fi
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
read -p "	(Please work with backed files) " inserts_dir
  sed -ri "s:(INSERTS_DIR=)(.*):\1${inserts_dir}:" ${CFG_WD}

echo -e "\nYour current settings are:"
echo $(cat ${CFG_WD})
echo -e "${blue}Don't forget to ${blink}restart${unblink} terminal or ${NC}source ${profile}"
echo -e "${green}Installation finished${NC}"

exit 0
