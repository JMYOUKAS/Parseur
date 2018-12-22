#!/bin/bash

# $1 : 1er argument

if [ -z "$1" ]; then
    echo "Il faut passer un dossier en argument"
    exit 1
fi

if [ -d "$1/CONVERT" ]; then
    rm -R "$1/CONVERT"
fi
if [ -d "$1/PARSE" ]; then
    rm -R "$1/PARSE"
fi

mkdir "$1/CONVERT"
mkdir "$1/PARSE"

for pdfPath in $1/*.pdf
do
    name=$(basename "$pdfPath" .pdf)
    convertedTxtPath="$1/CONVERT/$name.txt"
    pdftotext "$pdfPath" "$convertedTxtPath"

    echo "$name" >> "$1/PARSE/$name.txt"

    #Affiche le numero de la ligne de l'Abstract
    # echo "Debut de l'abstract"
    debut=`cat "$convertedTxtPath" | (grep -n '[aA][bB][sS][tT][rR][aA][cC][tT]' | head -1) | cut -d: -f1`
    # echo $debut

    #Affiche le numero de ligne -1 de Introduction
    # echo "Fin de l'abstract"
    fin=`cat "$convertedTxtPath" | (grep -n '[iI][nN][tT][rR][oO][dD][uU][cC][tT][iI][oO][nN]' | head -1) | cut -d: -f1`
    # echo $(($fin-1))
    finSansIntroduction=$(($fin-1))


    # echo "Abstract du document"
    abstract=`cat "$convertedTxtPath" | sed -n $debut,$finSansIntroduction'p'`
    # echo $abstract

    echo "$abstract" >> "$1/PARSE/$name.txt"
done
