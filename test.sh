#!/bin/bash

# $1 : 1er argument

mkdir $1/CONVERT
mkdir $1/PARSE

for f in $1/*.pdf; do
    echo "$f"
done