#!/bin/bash

set -e

script=$0
script_dir=$(cd "$(dirname "$0")" && pwd)

spec_file=$1

fatal() {
    if [ "${1}" != "" ]; then
    echo "Error: ${1}"
    fi
    usage
    exit 1
}

param_exists() {
    if [ "${1}" = "" ]; then
    fatal "${2}"
    fi
}

build() {
    echo "Building $spec_file"
    gem_file=`gem build $spec_file | grep File |  awk '{split($0, output,":"); print output[2] }'`
}

deploy() {
    echo "Deploying $gem_file"
    result=`gem push $gem_file`
    if [[ $result == *"Created"* ]]
    then
        echo "Gem $gem_file deployed to $nexus_url"
    else
        echo "Error uploading Gem"
        exit 1
    fi
}

param_exists "${spec_file}" "Gem spec file not specified"

build
deploy