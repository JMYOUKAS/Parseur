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

    echo "Nom du fichier :
    $name.pdf
" > "$1/PARSE/$name.txt"

    f="$convertedTxtPath"

    # TITRE
    a=`expr $a + 1`
    # echo ''
    # echo "Nouveau document"
    titre=''
    cat "$f" | while read line; 
    do
         #echo "$line"
        if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ 'www' ]] || [[ "$line" =~ '@' ]]; then
            if test -z "$titre"; then
            continue
            else
                #echo "VOICI LE TITRE COMPLET"
                #echo "$titre"
                
                echo "Titre : 
    $titre
" >> "$1/PARSE/$name.txt"
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

                        
                        #echo "VOICI L E TITRE COMPLET"
                        #echo "$titre"
                        echo "Titre :
    $titre
" >> "$1/PARSE/$name.txt"
                        #echo "a = $a"
                        break
                        
                    #Sinon
                    
                                       
                    else 
                        motVirgule=`echo "$line" | cut -d" " -f2`
                        virgule=`echo ${motVirgule:$((-1))}`
                        #echo "virgule : $virgule"
                        
                        if test `echo $motVirgule | grep ","`; then 
                            #echo $motVirgule
                            #echo "VOICI L E TITRE COMPLET"
                            #echo "$titre"
                        echo "Titre :
    $titre
" >> "$1/PARSE/$name.txt"
                       
                        break
                        else
                            #echo "titre = $titre"
                            titre="$titre $line"
                        fi
                        #echo "Le titre"
                        #echo "$titre"
                        #echo "$line"
                        ##titre="$titre $line"
                        # echo "$titre"
                    fi
                fi
            fi
        fi
    done


    # RESUME / ABSTRACT
    #Affiche le numero de la ligne de l'Abstract
    #echo "Debut de l'abstract"
    debut=`cat "$f" | (grep -n '[aA][bB][sS][tT][rR][aA][cC][tT]' | head -1) | cut -d: -f1`
    #echo $debut
    
    #Affiche le numero de ligne -1 de Introduction
    #echo "Fin de l'abstract"
    fin=`cat "$f" | (grep -n '[iI][nN][tT][rR][oO][dD][uU][cC][tT][iI][oO][nN]' | head -1) | cut -d: -f1`
    #echo $(($fin-1))
    
     if [[ `cat "$f"` =~ 'Keywords' ]]; then
        fin=`cat "$f" | (grep -n 'Keywords' | head -1) | cut -d: -f1`
        fin=$(($fin-1))
        abstract=`cat "$f" | sed -n $debut,$fin'p' | tr "\n" " " | cut -c10-` 

    elif [[ `cat "$f"` =~ 'Index Terms' ]]; then
        fin=`cat "$f" | (grep -n 'Index Terms' | head -1) | cut -d: -f1`
        fin=$(($fin-1))
        abstract=`cat "$f" | sed -n $debut,$fin'p' | tr "\n" " " | cut -c10-` 

        
    else
        #echo $abstract | head -n 22
        abstract=`cat "$f" | sed -n $debut,$(($fin-1))'p'` 
        #echo $abstract
        newFin=`echo "$abstract" | grep -n ['I\.''1''1\.'] | tail -1`
        newFinMot=`echo $newFin | grep [':1'':I?'] | cut -d: -f2`
        newFinLigne=`echo $newFin | grep [':1'':I?'] | cut -d: -f1`
       # echo $newFin
        if test `echo $newFinMot | wc -w` -le 2; then
            
            fin=$(($newFinLigne-1))   
        
                 
        fi
        #echo $fin
        #echo ""
        abstract=`echo "$abstract" | head -"$fin" | tr "\n" " " | cut -c10-` 
    fi

   
   # finSansIntroduction=$(($fin-1))
    

    #echo "Abstract du document"
    #abstract=`cat "$f" | sed -n $debut,$fin'p'` 
   
    # tr "\n" " " | cut -c10-
   # echo ""
    #echo $abstract

    
        
  
    #echo $abstract

    echo "Resumé/Abstract :
    $abstract
" >> "$1/PARSE/$name.txt"
done
