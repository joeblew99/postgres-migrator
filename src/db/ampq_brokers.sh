#!/bin/bash

set -e

ampq_brokers() {

	# set script variables
	local ENV=$1
	if [[ ! ${ENV} ]]; then
		echo "Environment variable is required."
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

	if [[ ${PG_DATABASE} == "transactions" ]]; then

		if [[ ${ENV} == "production" ]]; then
			sudo psql -v ON_ERROR_STOP=1 -h ${PG_SERVER} -U ${PG_USER} -d ${PG_DATABASE} <<-EOSQL
                INSERT INTO amqp.broker (broker_id, host, port, vhost, username, password) VALUES (1, 'pub-rabbit.docker.qarson.tech', 5672, 'access', 'access', 'z878SnreUNgjy5UH'); 
			EOSQL
			exit 0
		fi

		if [[ ${ENV} == "staging" ]]; then
			sudo psql -v ON_ERROR_STOP=1 -h ${PG_SERVER} -U ${PG_USER} -d ${PG_DATABASE} <<-EOSQL
	        	INSERT INTO amqp.broker (broker_id, host, port, vhost, username, password) VALUES (1, 'rc.edp', 5672, 'access', 'access', '5JrSK#-3');
			EOSQL
			exit 0
		fi

		if [[ ${ENV} == "development" ]]; then
			sudo psql -v ON_ERROR_STOP=1 -h ${PG_SERVER} -U ${PG_USER} -d ${PG_DATABASE} <<-EOSQL
		        INSERT INTO amqp.broker (broker_id, host, port, vhost, username, password) VALUES (1, 'w.edp', 5672, 'access', 'access', '5JrSK#-3');
			EOSQL
			exit 0
		fi
	fi

	exit 0
}