#!/bin/bash

set -e

restore_audit() {

	# set script variables
	local PG_SERVER=$1
	if [[ ! $PG_SERVER ]]; then
		echo "Restore database server name is required."
		exit 1
	fi

	local PG_USER=$2
	if [[ ! $PG_USER ]]; then
		echo "Restore database server user name is required."
		exit 1
	fi

	local PG_DATABASE=$3
	if [[ ! $PG_DATABASE ]]; then
		echo "Restore database name is required."
		exit 1
	fi

	sudo psql ${PG_DATABASE} < db/scripts/pg_audit.sql -v ON_ERROR_STOP=1 -h ${PG_SERVER} -U ${PG_USER}

}