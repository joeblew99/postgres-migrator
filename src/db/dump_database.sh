#!/bin/bash

set -e

# source get_postgres_version.sh

dump_database() {

	local PG_SERVER=$1
	if [[ ! $PG_SERVER ]]; then
		echo "Backup database server name is required."
		exit 1
	fi

	local PG_USER=$2
	if [[ ! $PG_USER ]]; then
		echo "Backup database server user name is required."
		exit 1
	fi

	local PG_DATABASE=$3
	if [[ ! $PG_DATABASE ]]; then
		echo "Backup database name is required."
		exit 1
	fi

	local S3_BUCKET=$4
	if [[ ! $S3_BUCKET ]]; then
		echo "Minio/S3 bucket name is required."
		exit 1
	fi

	local DUMP_FILE=$5
	if [[ ! $DUMP_FILE ]]; then
		echo "Dump file name is required."
		exit 1
	fi

	sudo pg_dump ${PG_DATABASE} --disable-triggers  -T 'audit.*' -h ${PG_SERVER} -U ${PG_USER} | gzip - | minio-client pipe ${S3_BUCKET}/${DUMP_FILE}
#	sudo -u postgres -H -- pg_dump ${PG_DATABASE} --disable-triggers  -h ${PG_SERVER} -U ${PG_USER} > /var/backups/postgresql/${DUMP_FILE}
}
