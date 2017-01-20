#!/usr/bin/env bash
#
# tasi.sh
# 
#
# Created by Andreas Bohn on 25/03/2014.
# Modified by Bruno Costa on 12/06/2015
# Copyright 2015 ITQB / UNL. All rights reserved.
#
# call tasi.sh [file] [source]

#rename inputs
FILE=$1
SOURCE=$2


# read softwares dir and workdirs
. ${SOURCE}/config/software_dirs.cfg
. ${SOURCE}/config/workdirs.cfg

if [[ $HEADLESS == "TRUE" ]]; then
	xserv=xvfb-run
fi

# configuration file paths
CFG="${SOURCE}/config/wbench_tasi.cfg"

printf "\nRan with these vars:\n#################\n#wbench_tasi.cfg#\n#################\n"
cat $CFG
printf "\n\n"

# define input directory and get input filename(s)
IN_FILE=$(basename $FILE)
IN_DIR=$(dirname $FILE)
IN_ROOT=${IN_FILE%.*}

#Check if there is more than one part
GENOME_BASENAME=$(basename $GENOME)
GENOME_DIR=$(dirname $GENOME)
echo "The genome used was "${GENOME_BASENAME}

# create output file
OUT_DIR=${workdir}"data/tasi"
mkdir -p $OUT_DIR
OUT_FILE=${OUT_DIR}"/"${IN_ROOT}_tasi

# run filter
RUN_TASI="${xserv} ${JAVA_DIR}/java -jar ${WBENCH_DIR}/Workbench.jar -tool tasi -f -srna_file ${FILE} -genome ${GENOME} -out_file ${OUT_FILE} -params ${CFG}"
echo "Ran tasi with the following command:"
echo " "${RUN_TASI}
$RUN_TASI

exit 0
