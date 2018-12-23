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

    echo "Nom du fichier : $name.pdf" >> "$1/PARSE/$name.txt"

    f="$convertedTxtPath"

    # TITRE
    a=`expr $a + 1`
    # echo ''
    # echo "Nouveau document"
    titre=''
    cat "$f" | while read line; 
    do
        if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ 'www' ]] || [[ "$line" =~ '@' ]]; then
            if test -z "$titre"; then
            continue
            else
                #echo "VOICI LE TITRE COMPLET"
                #echo "$titre"
                echo "Titre : $titre" >> "$1/PARSE/$name.txt"
                # echo "i2 : $i"
                break
            fi
        else
            #Si le titre est vide
            if test -z "$titre"; then
                #echo "Debut Titre"
                titre="$line"
                #echo "$titre";
            #Sinon
            else
                #si la ligne est vide
                if test -z "$line"; then
                    continue
                #Sinon
                else
                    word=`echo "$line" | wc -w`
                    #Si le nombre de mot est égale a 2               
                    if test $word -eq 2; then
                        echo "VOICI L E TITRE COMPLET"
                        echo "$titre"
                        echo "Titre : $titre" >> "$1/PARSE/$name.txt"
                        echo "a = $a"
                        break
                    #Sinon               
                    else 
                        #RAJOUTER LA VERIFICATION DES VIRGULES TOUTS LES DEUX MOTS (Juste sur le premier c'est suffisant)
                        #echo "Le titre"
                        #echo "$titre"
                        #echo "$line"
                        titre="$titre $line"
                        # echo "$titre"
                    fi
                fi
            fi
        fi
    done


    # RESUME / ABSTRACT
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

    echo "Résumé : $abstract" >> "$1/PARSE/$name.txt"
done
