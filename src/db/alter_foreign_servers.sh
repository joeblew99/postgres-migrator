#!/bin/bash

set -e

alter_foreign_servers() {

	# set script variables
	local ENV=$1
	if [[ ! ${ENV} ]]; then
		echo "Environment variable is required."
		exit 1
	fi

	local ENV_TEAM=$2
	if [[ ! ${ENV_TEAM} ]]; then
		echo "Envroinment team variable is required."
		exit 1
	fi

	local PG_SERVER=$3
	if [[ ! ${PG_SERVER} ]]; then
		echo "Restore database server name is required."
		exit 1
	fi

	local PG_USER=$4
	if [[ ! ${PG_USER} ]]; then
		echo "Restore database server user name is required."
		exit 1
	fi

	local PG_DATABASE=$5
	if [[ ! ${PG_DATABASE} ]]; then
		echo "Restore database name is required."
		exit 1
	fi

	if [[ ${PG_DATABASE} == "edp" ]]; then
		if [[ ${ENV} == "production" ]]; then
			sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
				ALTER SERVER transactions OPTIONS (SET host 'db.transactions.prod.edpauto.tech');
				ALTER SERVER transactionscluster OPTIONS (SET p0 'dbname=transactions host=db.transactions.prod.edpauto.tech port=5432');
			EOSQL
			exit 0
		fi
		if [[ ${ENV} == "staging" ]]; then
			sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
				ALTER SERVER transactions OPTIONS (SET host 'db.transactions.stg.edpauto.tech');
				ALTER SERVER transactionscluster OPTIONS (SET p0 'dbname=transactions host=db.transactions.stg.edpauto.tech port=5432');
				ALTER SERVER "qarson.fr" OPTIONS (SET host '10.0.0.222');
				ALTER SERVER "edpauto.fr" OPTIONS (SET host '10.0.0.222');
				ALTER SERVER cariam OPTIONS (SET host 'pgdba.cariam.stg.dacsoftware.it');
			EOSQL
			exit 0
		fi
		if [[ ${ENV} == "development" ]]; then
			sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
				ALTER SERVER transactions OPTIONS (SET host 'db.transactions.dev.edpauto.tech');
				ALTER SERVER transactionscluster OPTIONS (SET p0 'dbname=transactions host=db.transactions.dev.edpauto.tech port=5432');
				ALTER SERVER "qarson.fr" OPTIONS (SET host '10.0.0.222');
				ALTER SERVER "edpauto.fr" OPTIONS (SET host '10.0.0.222');
				ALTER SERVER cariam OPTIONS (SET host 'pgdba.cariam.stg.dacsoftware.it');
			EOSQL
			exit 0
		fi
	fi

	if [[ ${PG_DATABASE} == "transactions" ]]; then
		if [[ ${ENV} == "production" ]]; then
			sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
				ALTER SERVER edp OPTIONS (SET host 'db.stock.prod.edpauto.tech');
				ALTER SERVER enterprisecluster OPTIONS (SET p0 'dbname=edp host=db.stock.prod.edpauto.tech port=5432');
			EOSQL
			exit 0
		fi

		if [[ ${ENV} == "staging" ]]; then
			sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
				ALTER SERVER edp OPTIONS (SET host 'db.stock.stg.edpauto.tech');
				ALTER SERVER enterprisecluster OPTIONS (SET p0 'dbname=edp host=db.stock.stg.edpauto.tech port=5432');
			EOSQL
			exit 0
		fi

		if [[ ${ENV} == "development" ]]; then
		    if [[ ${ENV_TEAM} == "dotnet" ]]; then
				sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
					ALTER SERVER edp OPTIONS (SET host 'db.poz.stock.dev.dacsoftware.it');
					ALTER SERVER enterprisecluster OPTIONS (SET p0 'dbname=edp host=db.poz.stock.dev.dacsoftware.it port=5432');
				EOSQL
				exit 0
		    else
				sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
					ALTER SERVER edp OPTIONS (SET host 'db.stock.dev.edpauto.tech');
					ALTER SERVER enterprisecluster OPTIONS (SET p0 'dbname=edp host=db.stock.dev.edpauto.tech port=5432');
				EOSQL
				exit 0
		    fi
		fi
		sudo psql -v ON_ERROR_STOP=1 --username "${PG_USER}" -h ${PG_SERVER} -d ${PG_DATABASE} <<-EOSQL
			DROP SERVER IF EXISTS "edp" CASCADE;
			DROP SERVER IF EXISTS "enterprisecluster" CASCADE;
		EOSQL
	fi
	exit 0
}
