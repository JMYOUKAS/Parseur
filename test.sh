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

# Récupération du nom d'orgine
for f in $1/*.pdf
do
    filename=$(basename "$f")
    echo "$filename"
done

for f in $1/CONVERT/*.txt
do
    titre=""
    for line in $(cat $f)
    do
        #Si la ligne contient une date ou un mail ou vide
            #Ne rien faire
        if [ "$line" == *[0-9]* ] ||  [ "$line" == *[www]* ] || [ "$line" == *[@]*  ]; then
            echo 'Ce n est pas une ligne de titre, il y a des numeros, une adresse web ou mail'
            if [ $titre == "" ]
                continue
            else
                break
            fi
        fi
        #Aide : if [[$line == *[0-9]* ]] // verifie si ya un chiffre
        
        if [ $titre == "" ]; then
            titre=$line            
            echo "$titre"
        else
            if [ ̀`wc -w "$line"` > 2 ]; then
                titre=$titre $line
                echo "$titre"        
            else
                break
            fi
        fi

        #Sinon 
            #Si 1er Ligne Alors
                #On ajoute cette ligne dans le titre
            #Si ligne qui suis celle du debut titre Alors
                #On verifie que la ligne possède + de 2 mot, pas de virgule tout les deux mots
                    #Si OK Alors
                        #On ajoute cette ligne a la precedente
                    #Sinon
                        #Ne rien faire
            #Si titre terminé alors
                #Sortir de la boucle
    done        
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


