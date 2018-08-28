#!/bin/bash

# install Minio CLI client

# define the boundaries after which the message will be sent will be sent as an attachment
# count "c" characters or "l" lines from stdin 
# stdin_check="l"
# define number of characters or lines from stdin
# stdin_count="2"

set -e

minio() {

    # define usage function
    function usage {
        echo "Bash function to install Minio CLI client"
        echo
        echo "Define S3 server connection parameters:"
        echo " -h \"Host name\""
        echo " -e \"Endpoint Url\""
        echo " -a \"Access key\""
        echo " -k \"Secret key\""
        echo
        echo "Define logging provider:"
        echo " -A \"Logging application name\""
        echo " -L \"logging provider (console, logfile, slack)\""
        echo
        echo "Otherwise, define message using standard input."
        echo
        echo "Example: minio [-h <arg1> -e <arg2> -a <arg3> -k <arg4> -A <arg5> -L <arg6>]" 1>&2;
    }

    # display usage if no arguments are passed
    if [ "$#" = "0" ];then
        usage;
        exit;
    fi

    # parse arguments
    local OPTIND option
    while getopts "h:e:a:k:A:L:" option; do
        case $option in
            "h")
            local s3_host=${OPTARG}
            ;;
            "e")
            local s3_url=${OPTARG}
            ;;
            "a")
            local s3_access=${OPTARG}
            ;;
            "k")
            local s3_secret=${OPTARG}
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
        local log_app="Install Minio Client"
    fi
   
    if [ -z "$s3_host" ]; then
        logger -a "${log_app}" -p "${log_provider}" -l "ERROR" -m "S3 host name parameter are missing"
        exit 1
    fi

    if [ -z "$s3_url" ]; then
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

    cwd=$(pwd)

    # curl is an essential application used to send message
    # if ! command -v minio-client &>/dev/null; then
    local MINIO_DIR=/usr/share/minio-client

    # Install Minio client
    if [ ! -d ${MINIO_DIR} ]; then
        mkdir ${MINIO_DIR}
    fi

    rm -v -f ${MINIO_DIR}/mc

    logger -a "${log_app}" -p "${log_provider}" -l "NOTICE" -m "Download and install Minio client"
    wget -P ${MINIO_DIR} https://dl.minio.io/client/mc/release/linux-amd64/mc
    chmod +x ${MINIO_DIR}/mc

    rm -v -f /bin/minio-client
    rm -v -f /usr/local/bin/minio-client

    ln -s ${MINIO_DIR}/mc /usr/local/bin/minio-client

    # Initialize bucket
    minio-client config host add ${s3_host} ${s3_url} ${s3_access} ${s3_secret} S3v4

    cd ${cwd}
}
