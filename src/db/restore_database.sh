#!/bin/bash

set -e

# source get_postgres_version.sh

restore_database() {

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

	local PG_DUMPFILE=$4
	if [[ ! ${PG_DUMPFILE} ]]; then
		echo "Backup dump file path is required."
		exit 1
	fi

	if [[ ! $5 ]]; then
		local PG_TEMPLATE="template4"
	else
		local PG_TEMPLATE=$5
	fi

	# Remove old WAL log files
	# find /var/lib/postgresql/10/main/pg_wal/* -mtime +2 -exec rm {} \;

	# Restore database
	echo "Kill all connections to: ${PG_DATABASE} on host: ${PG_SERVER}."
	sudo psql -v ON_ERROR_STOP=1 --username ${PG_USER} -h ${PG_SERVER} -d postgres <<-EOSQL
			SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${PG_DATABASE}';;
	EOSQL

	echo "Drop database: ${PG_DATABASE} on host: ${PG_SERVER}."
	sudo psql -v ON_ERROR_STOP=1 --username ${PG_USER} -h ${PG_SERVER} -d postgres <<-EOSQL
        	DROP DATABASE IF EXISTS ${PG_DATABASE};
	EOSQL

	echo "Create database: ${PG_DATABASE} on host: ${PG_SERVER}."
	sudo psql -v ON_ERROR_STOP=1 --username ${PG_USER} -h ${PG_SERVER} -d postgres <<-EOSQL
        	CREATE DATABASE ${PG_DATABASE}
                WITH OWNER = postgres
                TEMPLATE = ${PG_TEMPLATE}
    			ENCODING = 'UTF8'
    			LC_COLLATE = 'en_US.UTF-8'
    			LC_CTYPE = 'en_US.UTF-8'
    			TABLESPACE = pg_default
    			CONNECTION LIMIT = -1;
	EOSQL
	sudo psql -v ON_ERROR_STOP=1 --username ${PG_USER} -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
        GRANT CONNECT, TEMPORARY ON DATABASE ${PG_DATABASE} TO public;
        GRANT ALL ON DATABASE ${PG_DATABASE} TO postgres;
	EOSQL

	if [[ ${PG_DATABASE} == "transactions" ]]; then
		grant_priviledges ${PG_SERVER} ${PG_USER} ${PG_DATABASE}
	fi

	if [[ ${PG_DATABASE} == "pgcrontab" ]]; then
		create_pgcron_extension ${PG_SERVER} ${PG_DATABASE} ${PG_USER}
	fi

	echo "Restore database: ${PG_DATABASE} on host: ${PG_SERVER}."
	sudo psql ${PG_DATABASE} <  ${PG_DUMPFILE} -h ${PG_SERVER} -U ${PG_USER}
	sudo psql -v ON_ERROR_STOP=1 --username ${PG_USER} -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
        VACUUM FULL ANALYZE;
	EOSQL
}
