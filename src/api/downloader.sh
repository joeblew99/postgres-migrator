#!/bin/bash

set -e

downloader() {

	# define usage function
	function usage {
        echo "Downloader an object from Minio to set path"
        echo
		echo "Define S3 server connection parameters:"
		echo " -b \"Pull an object endpoint\""
		echo " -p \"Destination an object folder path\""
		echo " -d \"Database object name\""
		echo " -f \"Full name of pull database dump object (optional)\""
		echo
        echo "Define logging provider:"
        echo " -A \"Logging application name (optional)\""
        echo " -L \"logging provider (console, logfile, slack) (optional)\""
        echo
        echo "Otherwise, define message using standard input."
        echo
        echo "Example: downloader [-b <arg1> -p <arg2> -d <arg3> -f <arg4> -A <arg5> -L <arg6>]" 1>&2;
        echo
	}

	# display usage if no arguments are passed
	if [ "$#" = "0" ];then
		usage;
		exit;
	fi

    # parse arguments
    local OPTIND option
    while getopts "b:p::d:f:A:L:" option; do
        case $option in
            "b")
            local s3_bucket_endpoint=${OPTARG}
            ;;
            "p")
            local pg_backup_path=${OPTARG}
            ;;
            "d")
            local pg_database=${OPTARG}
            ;;
            "f")
            local pg_dump_file=${OPTARG}
            ;;
            "A")
            local log_app=${OPTARG}
            ;;
            "L")
            local log_provider=${OPTARG}
            ;;
            \?|:)
            usage
            exit
            ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "$log_provider" ]; then
        local log_provider="slack"
    fi

    if [ -z "$log_app" ]; then
        local log_app="Download database dump from S3 bucket"
    fi

    if [ -z "${s3_bucket_endpoint}" ]; then
        logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 bukcet endpoint is missing."
        exit 1
    fi

    if [ -z "${pg_backup_path}" ]; then
        logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "Postgres backup folder path is missing."
        exit 1
    fi

    if [ -z "${pg_database}" ]; then
        logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "Restore PostgreSQL database is missing."
        exit 1
    fi

	# # Now, we support dump target - Minio server or local file server
	if [[ -z ${pg_dump_file} ]]; then    		
		FILES=()
		for i in $(minio-client ls ${s3_bucket_endpoint}); 
			do  
				if [[ ${i} == "${pg_database}"*".zip"* ]]; then
			 		FILES+=(${i})
			 	fi;	
		done;

		SORTED_FILES=($(sort <<<"${FILES[*]}"))
		local COMPRESSED_DUMP_FILE=${SORTED_FILES[-1]}
	else
		local COMPRESSED_DUMP_FILE=${pg_dump_file}
	fi

	minio-client cp ${s3_bucket_endpoint}/${COMPRESSED_DUMP_FILE} ${pg_backup_path}/${COMPRESSED_DUMP_FILE}

	local DUMP_FILE="${COMPRESSED_DUMP_FILE%%.*}".dumpfile
    echo "Decompressing ${COMPRESSED_DUMP_FILE} to ${DUMP_FILE}."
	gzip -dc ${pg_backup_path}/${COMPRESSED_DUMP_FILE} > ${pg_backup_path}/${DUMP_FILE}
	rm -f ${pg_backup_path}/${COMPRESSED_DUMP_FILE}

	chmod -R 0755 ${pg_backup_path}

	PG_DUMPFILE=${pg_backup_path}/${DUMP_FILE}
}