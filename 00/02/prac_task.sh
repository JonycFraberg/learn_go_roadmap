#!/bin/bash

DIR=${1:-.}

COUNT=$(find "$DIR" -name "*.go" -not -path "*/vendor/*" | wc -l)

if [ "$COUNT" -eq 0 ] 
then
    echo "No files"
    exit 0
fi

echo "files: \$COUNT"
find "$DIR" -name "*.go" -not -path "*/vendor/*" -exec wc -l {} + | sort -n
