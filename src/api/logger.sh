#!/bin/bash

# Utilities function for logging notice, warning and error messages

set -e

logger() {

    # define usage function
    function usage {
        echo "Bash function using to logging any errors, warnings or notices"
        echo
        echo "Basic logger parameters:"
        echo " -a \"Application Name\""
        echo " -p \"Provider [Console (Always if not Verbose), Log, Slack]\""
        echo " -l \"Logging level [Error, Warning, Notice]\""
        echo " -v \"Verbose logging to console\""
        echo
        echo "Define message using parameter:"
        echo " -m \"message\""
        echo
        echo "Otherwise, define message using standard input."
        echo
        echo "Example: logger [-a <arg1> -p <arg2> -l <arg3> -m <arg4>]" 1>&2;
    }

    # display usage if no arguments are passed
    if [ "$#" = "0" ]; then
        usage;
        exit;
    fi

    # parse arguments
    local OPTIND option
    while getopts "a:p:l:m:v" option; do
        case $option in
            "a")
            local apps=${OPTARG}
            ;;
            "p")
            local provider=${OPTARG}
            ;;
            "l")
            local level=${OPTARG}
            ;;
            "m")
            local message=${OPTARG}
            ;;
            "v")
            local verbose="true"
            ;;
            \?|:)
            usege
            exit
            ;;
        esac
    done
    shift $((OPTIND-1))

    # verify basic parameters
    if [ -z "${apps}" ] || [ -z "${provider}" ] || [ -z "${level}" ] || [ -z "${message}" ]; then
        echo "ERROR: Logging parameters are missing"
        exit 1
    fi

    if [ -z "${verbose}" ]; then
        local verbose="false"
    fi

    # log to console
    local log_time=`date +%Y.%m.%d-%H:%M:%S`
    local log_date=`date +%Y%m%d`

    # log to file
    if [[ "${provider^^}" == *"LOGFILE"* ]]; then
        local log_dir=/var/log/postgresql

        if [ ! -d ${log_dir} ]; then 
            mkdir ${log_dir}
        fi

        if [ "${level^^}" == "ERROR" ] || [ "${level^^}" == "WARNING" ] || [ "${level^^}" == "NOTICE" ]; then
            echo "Logger: A new [${level^^}] source on [${log_time}] from application [${apps}] :: ${message}." >> ${log_dir}/postgres_migration_${log_date}.log
        fi
    fi

    # log to Slack
    if [[ "${provider^^}" == *"SLACK"* ]]; then
        local slack_url="https://hooks.slack.com/services/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"
        local slack_channel=alerta
        local slack_user="Postgres Migrator"
        local slack_icon="postgres"

        if [ "${level^^}" == "ERROR" ]; then
            local slack_title="A new exception source: ${apps}." 
            local slack_message="Throw a new exception message: ${message}."
            slack -h "${slack_url}" -c ${slack_channel} -u "${slack_user}" -i ${slack_icon} -C B50718 -T "${slack_title}" -m "${slack_message}"
        fi

        if [ "${level^^}" == "WARNING" ]; then
            local slack_title="A new warning source: ${apps}." 
            local slack_message="Send a new warning message: ${message}"
            slack -h "${slack_url}" -c ${slack_channel} -u "${slack_user}" -i ${slack_icon} -C F9CD04 -T "${slack_title}" -m "${slack_message}"
        fi

        if [ "${level^^}" == "NOTICE" ]; then
            local slack_title="A new message source: ${apps}." 
            local slack_message="Send a new notice message: ${message}"
            slack -h "${slack_url}" -c ${slack_channel} -u "${slack_user}" -i ${slack_icon} -C 1974D2 -T "${slack_title}" -m "${slack_message}"
        fi
    fi

    if [ "${verbose}" == "true" ]; then
        if [ "${level^^}" == "ERROR" ] || [ "${level^^}" == "WARNING" ] || [ "${level^^}" == "NOTICE" ]; then
            echo "Console: A new [${level^^}] source on [${log_time}] from application [${apps}] :: ${message}."
        else
            echo "ERROR: Non valid logging level."
            exit 1
        fi
    fi
}
