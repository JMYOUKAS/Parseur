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

i=0

for f in $1/*.pdf
do
    nom=$(basename "$f" .pdf)
    chemin="$1/CONVERT/$nom.txt"
    pdftotext "$f" "$chemin"
    originalFilenames[$i]="$nom"
    i=$i+1
done

for f in $1/CONVERT/*.txt
do
    nouveau_nom=`echo $f | tr " " "_"`
    if [ "$nouveau_nom" != "$f" ]; then
        mv -i "$f" $nouveau_nom
    fi
done

i=0

# Récupération du nom d'orgine
for f in $1/*.pdf
do
    filename=$(basename "$f")
    # echo "$filename"
    
    echo "Nom du fichier :
    $filename
" > "$1/PARSE/${originalFilenames[$i]}.txt"
    i=$(($i+1))
    echo "i : $i"
done

a=-1

# Récupération du titre
for f in $1/CONVERT/*.txt;
do
    a=`expr $a + 1`
    # echo ''
    # echo "Nouveau document"
    titre=''
    cat $f | while read line; 
    do
 
        if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ 'www' ]] || [[ "$line" =~ '@' ]]; then
            if test -z "$titre"; then
            continue
            else
                #echo "VOICI LE TITRE COMPLET"
                #echo "$titre"
                echo "Titre : 
    $titre
" >> "$1/PARSE/${originalFilenames[$a]}.txt"
               
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
                        echo "Titre :
    $titre
" >> "$1/PARSE/${originalFilenames[$a]}.txt"
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
done

i=0

# RECUPERER L'ABSTRACT
for f in $1/CONVERT/*.txt
do
    #Affiche le numero de la ligne de l'Abstract
    #echo "Debut de l'abstract"
    debut=`cat $f | (grep -n '[aA][bB][sS][tT][rR][aA][cC][tT]' | head -1) | cut -d: -f1`
    #echo $debut

    #Affiche le numero de ligne -1 de Introduction
    #echo "Fin de l'abstract"
    fin=`cat $f | (grep -n '[iI][nN][tT][rR][oO][dD][uU][cC][tT][iI][oO][nN]' | head -1) | cut -d: -f1`
    #echo $(($fin-1))
    finSansIntroduction=$(($fin-1))


    #echo "Abstract du document"
    abstract=`cat $f | sed -n $debut,$finSansIntroduction'p' | tr "\n" " " | cut -c10-`
    #echo $abstract

    echo "Resumé/Abstract :
    $abstract
" >> "$1/PARSE/${originalFilenames[$i]}.txt"
    i=$(($i+1))
done



   # a='amelie'
   # if [ "$a" == "amelie" ]; then
   #     echo "true"
   # fi
   # [[ "$line" =~ *[0-9]* ]] && echo $line;
        #Si la ligne contient une date ou un mail ou vide
            #Ne rien faire
        
        #Aide : if [[$line == *[0-9]* ]] // verifie si ya un chiffre
# -z $line
     