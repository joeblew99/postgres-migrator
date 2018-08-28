#!/bin/bash

set -e

restores_postgres_roles() {

	#set script variables
	local PG_SERVER=$1
	if [[ ! $PG_SERVER ]]; then
		echo "Restore database server name is required."
		exit 1
	fi

	local PG_USER=$2
	if [[ ! $PG_USER ]]; then
		echo "	Restore database server user name is required."
		exit 1
	fi

	local PG_DATABASE=$3
	if [[ ! $PG_DATABASE ]]; then
		echo "Restore database name is required."
		exit 1
	fi

	local PG_BUCKET=$4
	if [[ ! ${PG_BUCKET} ]]; then
		echo "Minio/S3 bucket name is required."
	  	exit 1
	fi

	local PG_BACKUP=$5
	if [[ ! ${PG_BACKUP} ]]; then
		echo "Local backup directory path is required."
		exit 1
	fi

	if [[ ! $6 ]]; then
		local PG_SCRIPT=db_users_roles.sql
	else
		local PG_SCRIPT=$6
	fi

	# check and remove dump files and directories
	if [ -x ${PG_BACKUP} ]; then 
		rm -f ${PG_BACKUP}/${PG_SCRIPT}
	else 
	  	echo "Local backup direcotry does not exists."
	  	exit 1
	fi

	# Now, we support dump target - Minio server or local file server
	minio-client cp ${PG_BUCKET}/${PG_SCRIPT} ${PG_BACKUP}/${PG_SCRIPT}

	chmod -R 0775 ${PG_BACKUP}

	sudo psql ${PG_DATABASE} < ${PG_BACKUP}/${PG_SCRIPT} -h ${PG_SERVER} -U ${PG_USER}
}
