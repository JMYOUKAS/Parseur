#!/bin/bash

# $1 : 1er argument
if [ -d "$1/CONVERT" ]; then
    rm -R "$1/CONVERT"
fi
if [ -d "$1/PARSE" ]; then
    rm -R "$1/PARSE"
fi

mkdir $1/CONVERT
mkdir $1/PARSE

for f in $1/*.pdf
do
    nom=$(basename "$f" .pdf)
    chemin="$1/CONVERT/$nom.txt"
    pdftotext "$f" "$chemin"    
done

for f in $1/CONVERT/*.txt
do
    nouveau_nom=`echo $f | tr " " "_"`
    if [ "$nouveau_nom" != "$f" ]; then
        mv -i "$f" $nouveau_nom
    fi
done

# Récupération du nom d'orgine
for f in $1/*.pdf
do
    filename=$(basename "$f")
    echo "$filename"
done