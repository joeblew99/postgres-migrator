#!/bin/bash

set -e

grant_priviledges() {

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

	sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
		ALTER DEFAULT PRIVILEGES 
		    GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
		    TO public;

		ALTER DEFAULT PRIVILEGES 
		    GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
		    TO "dariusz.tarczynski";

		ALTER DEFAULT PRIVILEGES 
		    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
		    TO public;

		ALTER DEFAULT PRIVILEGES 
		    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
		    TO "dariusz.tarczynski";
	EOSQL


}