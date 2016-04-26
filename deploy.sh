#!/bin/bash

set -e

script=$0
script_dir=$(cd "$(dirname "$0")" && pwd)

usage() {
    echo "Usage:
${script} -r|--repo=<nexus-repo-url> \
-u|-user=<nexus-repo-user> \
-p|--password=<nexus-repo-password>"
}

for i in "$@"
do
case $i in
    --help*)
    usage
    exit 0
    ;;
    -r=*|--repo=*)
    nexus_url="${i#*=}"
    shift
    ;;
    -u=*|--user=*)
    nexus_user="${i#*=}"
    shift
    ;;
    -p=*|--password=*)
    nexus_pass="${i#*=}"
    shift
    ;;
    *)
    ;;
esac
done

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
    echo "Building testrail_integration.gemspec"
    gem_file=`gem build testrail_integration.gemspec | grep File |  awk '{split($0, output,":"); print output[2] }'`
}

configure_deploy() {
    echo "Creating deploy configuration"
    auth=`echo -ne "$nexus_user:$nexus_pass" | base64`
    rm -f $script_dir/nexus.conf 2> /dev/null
    erb nexus_url=$nexus_url auth=$auth ./nexus.conf.erb > $script_dir/nexus.conf
}

deploy() {
    configure_deploy
    echo "Deploying $gem_file"
    result=`gem nexus $gem_file --nexus-config $script_dir/nexus.conf`
    if [[ $result == *"Created"* ]]
    then
        echo "Gem $gem_file deployed to $nexus_url"
    else
        echo "Error uploading Gem"
        exit 1
    fi
}

param_exists "${nexus_url}" "nexus repository not specified"
param_exists "${nexus_pass}" "nexus username not specified"
param_exists "${nexus_user}" "nexus password not specified"

build
deploy