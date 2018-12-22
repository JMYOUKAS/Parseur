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
mkdir "$1/TMP"

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


# RECUPERER L'ABSTRACT
for f in $1/CONVERT/*.txt
do
    #Affiche le numero de la ligne de l'Abstract
    echo "Debut de l'abstract"
    debut=`cat $f | (grep -n '[aA][bB][sS][tT][rR][aA][cC][tT]' | head -1) | cut -d: -f1`
    echo $debut

    #Affiche le numero de ligne -1 de Introduction
    echo "Fin de l'abstract"
    fin=`cat $f | (grep -n '[iI][nN][tT][rR][oO][dD][uU][cC][tT][iI][oO][nN]' | head -1) | cut -d: -f1`
    echo $(($fin-1))
    finSansIntroduction=$(($fin-1))


    echo "Abstract du document"
    abstract=`cat $f | sed -n $debut,$finSansIntroduction'p'`
    echo $abstract
done

# Récupération du nom d'orgine
for f in $1/*.pdf
do
    filename=$(basename "$f")
    echo "$filename"
done
