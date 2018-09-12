#!/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function getFastq {

	WORKDIRS_CFG="${DIR}/../config/workdirs.cfg"	
	WORKDIRS_BK=$(backupFile $WORKDIRS_CFG)

	WORKDIR_RUN=${DIR}/workdir/
	
	sed -ri "s:^(INSERTS_DIR=).*$:\1${DIR}/inserts_dir:g" $WORKDIRS_CFG
	sed -ri "s:^(workdir=).*$:\1${WORKDIR_RUN}:g" $WORKDIRS_CFG
	cat $WORKDIRS_CFG
	${DIR}/.././miRPursuit.sh --fastq - -f 119 -l 127 --test
	restoreFile ${WORKDIRS_BK}
	cleanUp $WORKDIR_RUN
	
}


function cleanUp {
	WORKDIR=$1
	if [[ -n "$WORKDIR" ]]; then 
		rm -r $WORKDIR
	fi

}
function backupFile {
	#Store a backup of the current file
	FILE=$1
	BACKUP_FILE=$(dirname ${FILE})"/."$(basename ${FILE}).backup
	
	cp ${FILE} ${BACKUP_FILE}
	
	echo ${BACKUP_FILE}
}

function restoreFile {
	#Replace the main file with the backup
	BACKUP_FILE=$1
	
	bk_base=$(basename $BACKUP_FILE)
	bk_base=${bk_base%%.backup}
	bk_base=${bk_base##.}
	
	bk_dir=$(dirname $BACKUP_FILE)

	MAIN_FILE=${bk_dir}/${bk_base}

	mv ${BACKUP_FILE} ${MAIN_FILE}
}

getFastq

exit 0;