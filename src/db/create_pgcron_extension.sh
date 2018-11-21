
#!/bin/bash

set -e

create_pgcron_extension() {

	# Set script variables
	local PG_SERVER=$1
	if [[ ! ${PG_SERVER} ]]; then
		echo "Restore database server name is required."
		exit 1
	fi

	local PG_DATABASE=$2
	if [[ ! $PG_DATABASE ]]; then
		echo "Backup database name is required."
		exit 1
	fi

	local PG_USER=$3
	if [[ ! $PG_USER ]]; then
		PG_USER=postgres
	fi

	echo "Create pg_cron"
	### Init cron tab extension
	sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
		CREATE EXTENSION IF NOT EXISTS pg_cron;
		GRANT USAGE ON SCHEMA cron TO pgcron;
	EOSQL
}


