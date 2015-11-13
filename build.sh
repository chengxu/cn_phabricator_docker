#!/bin/bash
if [ $# != 1 ] ; then 
    echo "USAGE: $0 <version> " 
    echo " e.g.: $0 v2" 
    exit 1; 
fi 
version=${1}

docker build -t phabricator:${version} .
