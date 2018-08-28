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
source api/downloader.sh

source db/restore_database.sh
source db/grant_priviledges.sh
source db/restore_audit.sh
source db/alter_foreign_servers.sh
source db/ampq_brokers.sh
source db/replace_contact_mail.sh

# define usage function
function usage {
    echo "Restore PostgreSQL database instance and pull from S3 storage"
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
    echo " -u \"Username\""
    echo " -w \"Prompt password (Yes, otherwise is no prompts)\""
    echo " -c \"Cluster name\""
    echo " -d \"Database name\""
    echo " -t \"Database template\""
    echo
    echo "Define dump using file and bucket names:"
    echo " -O \"Only restore database without download dump image\""
    echo " -F \"Dump source file path\""
    echo " -T \"Dump target bucket path\""
    echo
    echo "Define logging parameters:"
    echo " -L \"logging provider (console, logfile, slack)\""
    echo " -v \"Verbose logging to console\""
    echo
    echo "Otherwise, define message using standard input."
    echo
    echo "Example:  restoredb [-n <arg1> -o <arg2> -m <arg3> -b <arg4> -e <arg5> -a <arg6> -k <arg7> "
    echo "                  -h <arg8> -u <arg9> -w <arg10> -c <arg11> -d <arg12> -t <arg13>]"
    echo
}

# display usage if no arguments are passed
if [ "$#" = "0" ];then
    usage;
    exit;
fi


# parse arguments
while getopts "n:o:m:b:e:a:k:h:u:w:c:d:t:O:F:T:L:v" option; do
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
	"t")
	pg_template=${OPTARG}
	;;
        "O")
        only_restore=${OPTARG}
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

if [ -z "$pg_port" ]; then
    pg_port="5432"
fi

if [ -z "$pg_user" ]; then
    pg_user="postgres"
fi

if [ -z "$pg_database" ]; then
    pg_database=${pg_cluster}
fi

if [ -z "$pg_template" ]; then
   pg_template="template4"
fi

log_app="Restore PostgreSQL database from bucket: [${s3_bucket}]@[${s3_endpoint}], to database: [${pg_database}].[${pg_cluster}]@${pg_host}."

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

# check and remove dump files and directories
if [ -x ${PG_BACKUP_DIR} ]; then 
    rm -f ${PG_BACKUP_DIR}/*.zip
else 
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "Local backup folder doesn't exist."
    exit 1
fi

cwd=$(pwd)

# Download database dump
if [ -z ${only_restore} ]; then

    # Install Minio Client
    minio -h ${s3_server} -e ${s3_endpoint} -a ${s3_access} -k ${s3_secret} -A ${log_app} -L ${log_provider}
    cwd=$(pwd)

	# remove old dump files
	rm -f ${PG_BACKUP_DIR}/${pg_database}_*

    if [ -z ${dump_file} ]; then
        downloader -b "${bucket_path}/dumps" -p "${PG_BACKUP_DIR}" -d ${pg_database} -A ${log_app} -L ${log_provider}
    else
        downloader -b "${bucket_path}/dumps" -p "${PG_BACKUP_DIR}" -d ${pg_database} -f "${dump_file}" -A ${log_app} -L ${log_provider}
    fi;
else
	if [[ -z ${dump_file} ]]; then    		
		FILES=()
		for i in $(ls ${PG_BACKUP_DIR}); 
			do  
    			if [[ ${i} == "${pg_database}"*".dumpfile"* ]]; then
			 		FILES+=(${i})
			 	fi;	
		done;

		SORTED_FILES=($(sort <<<"${FILES[*]}"))
		PG_DUMPFILE=${PG_BACKUP_DIR}/${SORTED_FILES[-1]}
	else
		PG_DUMPFILE=${dump_file}
	fi;
fi
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on during download dump of ${pg_database} database from bucket: ${bucket_path} ." -v
    exit 1
fi

# Restore database
restore_database ${pg_host} ${pg_user} ${pg_database} "${PG_DUMPFILE}" ${pg_template}
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on restore  ${pg_database} database instance on ${pg_host} host." -v
    exit 1
fi

# Apply required changes on database after migration
restore_audit ${pg_host} ${pg_user} ${pg_database}
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on restore audit tables on ${pg_database} database instance on ${pg_host} host." -v
    exit 1
fi

# set foreign servers
alter_foreign_servers ${environment} ${team} ${pg_host} ${pg_user} ${pg_database}
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on alter foreign servers on ${pg_database} database instance on ${pg_host} host." -v
    exit 1
fi

ampq_brokers ${environment} ${pg_host} ${pg_user} ${pg_database}
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on replace AMPQ brokers endpoints on ${pg_database} database instance on ${pg_host} host." -v
    exit 1
fi

# replace contact mail
replace_contact_mail ${environment} ${pg_host} ${pg_user} ${pg_database}
if [ $? != 0 ]; then
    logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "ERROR on replace contact mails on ${pg_database} database instance on ${pg_host} host." -v
    exit 1
fi

cd ${pwd}
exit 0
