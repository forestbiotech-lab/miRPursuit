#!/bin/bash

# predict-target.sh
# 
#
# Created by Bruno Costa on 09/09/2015.
# Copyright 2015 ITQB / UNL. All rights reserved.
# Executes target.sh
# Call: predict-target.sh [LIB_FIRST] [LIB_LAST]


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
  -d|--degradome)
  DEGRADOME_arg="$2"
  shift # past argument
  ;;
  -h|--help)
  echo " 
  -f|--lib-first
  -l|--lib-last
  ---------------------
  Optional args
  ---------------------
  -d|--degradome is an optional argument if it isn't used if will be prompted giving the the options of the files in the directory last used. 
  -h|--help
  "
  exit 0
esac
shift # past argument or value
done

#Gets the script directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#Get config vars
. "${DIR}/config/workdirs.cfg"

if [[ -z $DEGRADOME_arg ]]; then
  DEG_ROOT=$(dirname ${DEGRADOME})
  list=$(ls ${DEG_ROOT})
  listComma=$(echo $list | tr " " ";")
  IFS=";" read -ra array_deg <<< "$listComma"
  counter=-1
  echo "Please choose the number that corresponds to the degradome you want to use:"
  for i in ${array_deg[@]};
  do
    (( counter++ ))     
    echo $counter" -" $i
  done        
  read deg
  while [[ "$deg" > "$counter" ]]; do
    echo "Must  be smaller than $counter"
    read deg
  done
  DEGRADOME_arg=${array_deg[$deg]}
  echo "Using ${DEGRADOME_arg} as degradome"

  tmpfile=$(mktemp -t workdir.XXXXXX)
  sed -r "s:(DEGRADOME=).*:\1${DEG_ROOT}/${DEGRADOME_arg}:" ${DIR}/config/workdirs.cfg > $tmpfile
  sed -r "s:(DEGRADOME=)$HOME(.*):\1\${HOME}\2:" $tmpfile > ${DIR}/config/workdirs.cfg
fi

if [[ -z $LIB_FIRST || -z $LIB_LAST ]]; then
  echo "Missing mandatory parameters"
  echo "use -h|--help for list of commands"
  exit 0
fi

echo "Running predict-target with the following arguments:"
echo "FIRST Library     = ${LIB_FIRST}"
echo "Last Library    = ${LIB_LAST}"
echo "Degradome = ${DEGRADOME_arg}"
#nonempty string bigger than 0
if [[ -n $1 ]]; then 
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi
##### arg to ensure lib_last is bigger then lib_first##


###################################################################################################

#Get config settings
. $DIR/"config/workdirs.cfg"

mkdir -p $workdir"log/"
log_file=$workdir"log/"$(echo $(date +"%y%m%d:%H%M%S")":"$(echo $$)":predict_target:"$2":"$3)".log"
echo ${log_file}
exec 2>&1 > ${log_file}

SCRIPT_DIR=$DIR"/scripts/"                

#run target.sh
echo "Running PAREsnip..."
${DIR}/scripts/target.sh $LIB_FIRST $LIB_LAST ${DIR}

ok_log=${log_file/.log/:OK.log}

echo $ok_log
mv $log_file $ok_log
printf "Workdir is: "$workdir"\nInserts dir is: "$INSERTS_DIR"\nfastq_xtract.sh ran in s\nlib_cat.sh ran in s\n" > $ok_log

exit 0
