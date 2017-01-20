#!/usr/bin/env bash

# filter_wbench.sh
# 
#
# Created by Andreas Bohn on 15/10/2014.
# Copyright 2014 ITQB / UNL. All rights reserved.

# call filter_wbench.sh [file] [source]

#rename variables
file=$1
source=$2



# read softwares dir
. ${source}"/config/software_dirs.cfg"
. ${source}"/config/workdirs.cfg"

if [[ $HEADLESS == "TRUE" ]]; then
	xserv=xvfb-run
fi

 
# configuration file path
CFG=${source}"/config/wbench_filter_in_use.cfg"

# define input directory and get input filename(s)
IN_FILE=$(basename ${file})
IN_DIR=$(dirname ${file})
IN_ROOT=${IN_FILE%.*}

# create output dir for csv if not existent
CSV_DIR=${workdir}"data/filter_overview/"
mkdir -p $CSV_DIR
OUT_CSV=${CSV_DIR}${IN_ROOT}"_filt-"${FILTER_SUF}".csv"
# create output file
OUT_FILE=${CSV_DIR}${IN_ROOT}"_filt-"${FILTER_SUF}".fa"

printf $(date +"%y/%m/%d-%H:%M:%S")" - Filtering ${IN_ROOT} with wbench.\n"

# run sRNA_Workbench filter if first time redirect output to stderr
if [[ "$RUN" == 0 ]]; then
 >&2 echo "                                                                                                      "
 >&2 ${xserv} ${JAVA_DIR}"/java" -jar ${WBENCH_DIR}"/Workbench.jar" -tool filter -f -srna_file ${file} -out_file $OUT_FILE -params $CFG
else
  ${xserv} ${JAVA_DIR}"/java" -jar ${WBENCH_DIR}"/Workbench.jar" -tool filter -f -srna_file ${file} -out_file $OUT_FILE -params $CFG
fi

# move and rename overview produced by wb_filter
mv ${OUT_FILE}_overview.csv ${OUT_CSV}

output_size=$(wc -l ${OUT_CSV} | awk '{print $1}')
if [[ ${output_size} == 0 ]]; then
	printf "###################\n##   ATTENTION ! ##\n###################\n###################\n"
	printf $(date +"%y/%m/%d-%H:%M:%S")" - Filtering ${IN_ROOT} generated no reads\n\tResults for this library ${IN_ROOT} will be irrelevant from this point on.\n"
	>&2 echo ""
	>&2 echo -e "${red}Attention${NC} - Filtering ${IN_ROOT} generated no reads but program will continue." 
	>&2 echo ""
else
	printf $(date +"%y/%m/%d-%H:%M:%S")" -  Filtered ${IN_ROOT} with wbench.\n"
fi

exit 0
