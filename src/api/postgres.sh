#!/bin/bash

set -e

postgres_version() {
    
    local version=$(echo "$(psql --version)" | grep "9.1")
    if [[ $version == *"9.1"* ]]; then
        echo "9.1"
        exit
    fi

    if [[ $version == *"10"* ]]; then
        echo "10"
        exit
    fi

    echo $version
}
