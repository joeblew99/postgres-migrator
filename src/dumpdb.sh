#!/bin/bash

# Restore PostgreSQL database from dumpfile stored on Minio S3 server

set -e

# # define the boundaries after which the message will be sent will be sent as an attachment
# # count "c" characters or "l" lines from stdin 
# stdin_check="l"
# # define number of characters or lines from stdin
# stdin_count="2"

source api/slack.sh
source api/logger.sh
source api/minio.sh
source api/postgres.sh

source db/dump_database.sh
source db/dump_roles.sh

# define usage function
function usage {
    echo "Dump PostgreSQL database instance and push to S3 storage"
    echo
    echo "Define basic parameters:"
    echo " -n enviroinment"
    echo " -o enviroiment team name"
    echo
    echo "Define S3 server connection parameters:"
    echo " -m \"Host name\""
    echo " -b \"Bucket name (only in DigitalOcean)\""
    echo " -e \"Endpoint URL\""
    echo " -a \"Access key\""
    echo " -k \"Secret key\""
    echo
    echo "PostgreSQL database using parameters:"  
    echo " -h \"Host name\""
    echo " -r \"Host Url\""
    echo " -u \"Username\""
    echo " -w \"Prompt password (Yes, otherwise is no prompts)\""
    echo " -c \"Cluster name\""
    echo " -d \"Database name\""
    echo
    echo "Define dump using file and bucket names:"
    echo " -F \"Dump source file path\""
    echo " -T \"Dump target bucket path\""
    echo
    echo "Define logging parameters:"
    echo " -L \"logging provider (console, logfile, slack)\""
    echo " -v \"Verbose logging to console\""
    echo
    echo "Otherwise, define message using standard input."
    echo
    echo "Example:  dumpdb [-n <arg1> -o <arg2> -m <arg3> -b <arg4> -e <arg5> -a <arg6> -k <arg7> "
    echo "                  -h <arg8> -u <arg9> -w <arg10> -c <arg11> -d <arg12>]"
    echo
}

# display usage if no arguments are passed
if [ "$#" = "0" ];then
    usage;
    exit;
fi

# parse arguments
while getopts "n:o:m:b:e:a:k:h:r:u:w:c:d:F:T:L:v" option; do
    case $option in
        "n")
        environment=${OPTARG}
        ;;
        "o")
        team=${OPTARG}
        ;;
        "m")
        s3_server=${OPTARG}
        ;;
        "b")
        s3_bucket=${OPTARG}
        ;;
        "e")
        s3_endpoint=${OPTARG}
        ;;
        "a")
        s3_access=${OPTARG}
        ;;
        "k")
        s3_secret=${OPTARG}
        ;;
        "h")
        pg_host=${OPTARG}
        ;;
        "r")
        pg_url=${OPTARG}
        ;;
        "u")
        pg_user=${OPTARG}
        ;;
        "w")
        pg_password=${OPTARG}
        ;;
        "c")
        pg_cluster=${OPTARG}
        ;;
        "d")
        pg_database=${OPTARG}
        ;;
        "F")
        dump_file=${OPTARG}
        ;;
        "T")
        bucket_path=${OPTARG}
        ;;
        "L")
        log_provider=${OPTARG}
        ;;
        "v")
        log_verbose=" -v"
        ;;
        \?|:)
        usage
        exit
        ;;
    esac
done

if [ -z "$log_provider" ]; then
    log_provider="console"
fi

if [ -z "$pg_host" ]; then
    pg_host="localhost"
fi

if [ -z "$pg_url" ]; then
    pg_url=${pg_host}
fi

if [ -z "$pg_port" ]; then
    pg_port="5432"
fi

if [ -z "$pg_user" ]; then
    pg_user="postgres"
fi

if [ -z "$pg_database" ]; then
    pg_database=${pg_cluster}
fi

dump_time=`date +%Y%m%d-%H%M`
#log_app="Dump PostgreSQL database: [${pg_database}].[${pg_cluster}]@${pg_host}, to bucket: [${s3_bucket}]@[${s3_endpoint}] "
log_app="Dump PostgreSQL database: ${pg_database}."

# verify basic parameters
if [ -z "$environment" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "Deployment environment parameter are missing"
    exit 1
fi

if [ -z "$team" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "Deployment environment team parameter are missing"
    exit 1
fi

if [ -z "$s3_server" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 server name parameter are missing"
    exit 1
fi

if [ -z "$s3_endpoint" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 server URL parameter are missing"
    exit 1
fi

if [ -z "$s3_access" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 server Access Key parameter are missing"
    exit 1
fi

if [ -z "$s3_secret" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 server Secret Key parameter are missing"
    exit 1
fi

if [ -z "$pg_cluster" ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "PostgreSQL cluster name parameter are missing"
    exit 1
fi

if [ -z "$dump_file"]; then
    dump_file=${pg_database}_dump_${dump_time}.zip
fi

if [ -z "$bucket_path"]; then
    if [ -z "$s3_bucket" ]; then
        bucket_path=${s3_server}/databases/${pg_cluster}
    else
        bucket_path=${s3_server}/${s3_bucket}/databases/${pg_cluster}
    fi
fi

PG_BACKUP_DIR=/var/backups/postgresql
PG_HOME=/etc/postgresql/${PG_VERSION}/main
PG_VERSION=postgres_version

echo "Postgres version: ${PG_VERSION}"

cwd=$(pwd)

# Install Minio Client
minio -h ${s3_server} -e ${s3_endpoint} -a ${s3_access} -k ${s3_secret} -A ${log_app} -L ${log_provider}

cwd=$(pwd)

# Dump database instance
if [[ ${environment} == "production" ]]; then
    dump_database ${pg_host} ${pg_user} ${pg_database} "${bucket_path}/dumps" "${dump_file}"
fi

# # Dump database roles
dump_roles ${pg_host} ${pg_user} ${pg_database} "${bucket_path}/roles/${environment}" "db_roles.sql"

log_pg_url=${pg_database}@${pg_url}

log_s3_url=${s3_endpoint#"https://"}
log_s3_url="https://"${s3_bucket}.${log_s3_url}


# Handle error
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "slack" -l "ERROR" -m "Error during backup PostgreSQL database: ${log_pg_url}, to S3 bucket: ${log_s3_url}."
    exit 2
fi

logger -a "${log_app}" -p "slack" -l "NOTICE" -m "Successful backup PostgreSQL database:  ${log_pg_url}, to S3 bucket: ${log_s3_url}."

cd ${pwd}
exit 0
