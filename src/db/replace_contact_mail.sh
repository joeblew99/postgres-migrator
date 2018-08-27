#!/bin/bash

set -e

replace_contact_mail() {

	# set script variables
	local ENV=$1
	if [[ ! ${ENV} ]]; then
		echo "Envroinment variable is required."
		exit 1
	fi

	local PG_SERVER=$2
	if [[ ! $PG_SERVER ]]; then
		echo "Restore database server name is required."
		exit 1
	fi

	local PG_USER=$3
	if [[ ! $PG_USER ]]; then
		echo "Restore database server user name is required."
		exit 1
	fi

	local PG_DATABASE=$4
	if [[ ! $PG_DATABASE ]]; then
		echo "Restore database name is required."
		exit 1
	fi

	if [[ ${ENV} == "production" ]]; then
		exit 0
	fi

	if [[ ${PG_DATABASE} != "transactions" ]]; then
		exit 0
	fi

	sudo psql -v ON_ERROR_STOP=1 -h ${PG_SERVER} -U ${PG_USER} -d ${PG_DATABASE} <<-EOSQL
		UPDATE access.partnerzy SET "ContactMAIL"=substring((replace("ContactMAIL", '@', '___') || '@crm.pl.edp') from 1 for 50) 
			WHERE "ContactMAIL" not like '%pl.edp';
	EOSQL
}