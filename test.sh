#!/bin/bash

# $1 : 1er argument
if [ -z "$1" ]; then
    echo "Il faut passer un dossier en argument"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Il faut donner un format de sortie -t ou -x"
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

i=1

for f in $1/*.pdf
do
    echo "$i) $(basename "$f" .pdf).pdf"
    files[$i]="$f"
    i=$(($i+1))
done

read input

IFS=',' read -r -a array <<< "$input"

i=0

for a in ${array[@]}; do
    f=${files[$a]}
    nom=$(basename "$f" .pdf)
    chemin="$1/CONVERT/$nom.txt"
    pdftotext "$f" "$chemin"
    originalFilenames[$i]="$nom"
    i=$(($i+1))
done

# i=0

# for f in $1/*.pdf
# do
#     nom=$(basename "$f" .pdf)
#     chemin="$1/CONVERT/$nom.txt"
#     pdftotext "$f" "$chemin"
#     originalFilenames[$i]="$nom"
#     i=$i+1
# done

for f in $1/CONVERT/*.txt
do
    nouveau_nom=`echo $f | tr " " "_"`
    if [ "$nouveau_nom" != "$f" ]; then
        mv -i "$f" $nouveau_nom
    fi
done

i=0

# Récupération du nom d'orgine
for f in $1/CONVERT/*.txt
do
    filename=$(basename "$f")
    # echo "$filename"
    
    # Ouverture de la balise article
    if [ $2 = "-x" ]; then
        echo "<article>" > "$1/PARSE/${originalFilenames[$i]}.xml"
    fi

    if [ $2 = "-t" ]; then
        echo "Nom du fichier :$filename" >> "$1/PARSE/${originalFilenames[$i]}.txt"
    elif [ $2 = "-x" ]; then
        echo "<preambule>$filename</preambule>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
    i=$(($i+1))    
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
         #echo "$line"
        if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ 'www' ]] || [[ "$line" =~ '@' ]]; then
            if test -z "$titre"; then
            continue
            else
                #echo "VOICI LE TITRE COMPLET"
                #echo "$titre"
                
                if [ $2 = "-t" ]; then
                    echo "Titre :
    $titre
" >> "$1/PARSE/${originalFilenames[$a]}.txt"
                elif [ $2 = "-x" ]; then
                    echo "<titre>$titre</titre>" >> "$1/PARSE/${originalFilenames[$a]}.xml"
                fi
               

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
                        if [ $2 = "-t" ]; then
                            echo "Titre :
    $titre
" >> "$1/PARSE/${originalFilenames[$a]}.txt"
                        elif [ $2 = "-x" ]; then
                            echo "<titre>$titre</titre>" >> "$1/PARSE/${originalFilenames[$a]}.xml"
                        fi
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
                        if [ $2 = "-t" ]; then
                            echo "Titre :
    $titre
" >> "$1/PARSE/${originalFilenames[$a]}.txt"
                        elif [ $2 = "-x" ]; then
                            echo "<titre>$titre</titre>" >> "$1/PARSE/${originalFilenames[$a]}.xml"
                        fi
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
    
     if [[ `cat $f` =~ 'Keywords' ]]; then
        fin=`cat $f | (grep -n 'Keywords' | head -1) | cut -d: -f1`
        fin=$(($fin-1))
        abstract=`cat $f | sed -n $debut,$fin'p' | tr "\n" " " | cut -c10-` 

    elif [[ `cat $f` =~ 'Index Terms' ]]; then
        fin=`cat $f | (grep -n 'Index Terms' | head -1) | cut -d: -f1`
        fin=$(($fin-1))
        abstract=`cat $f | sed -n $debut,$fin'p' | tr "\n" " " | cut -c10-` 

        
    else
        #echo $abstract | head -n 22
        abstract=`cat $f | sed -n $debut,$(($fin-1))'p'` 
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
    #abstract=`cat $f | sed -n $debut,$fin'p'` 
   
    # tr "\n" " " | cut -c10-
   # echo ""
    #echo $abstract

    
        
  
    #echo $abstract

    if [ $2 = "-t" ]; then
        echo "Resumé/Abstract :
    $abstract
" >> "$1/PARSE/${originalFilenames[$i]}.txt"
    elif [ $2 = "-x" ]; then
        echo "<abstract>$abstract</abstract>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
    i=$(($i+1))
done




i=0
# Récupération de l'INTRODUCTION
for f in $1/CONVERT/*.txt;
do
    newDebut=0
    debutIntrodution=`cat $f | (grep -n '[iI][nN][tT][rR][oO][dD][uU][cC][tT][iI][oO][nN]' | head -1) | cut -d: -f1`
    # echo "Debut de l'introdution : $debutIntrodution"

    finIntroduction=`cat $f | tail -n +$debutIntrodution | (egrep -n '^2$|^II|^2\. [A-Z]|^II.[A-Z]|^2\.$|^2.[A-Z]|^.?2$' | head -1)`
    ligneSuivante=$(($debutIntrodution+`echo $finIntroduction | cut -d: -f1`-1))
    # echo "fin de l'introdution : $finIntroduction"

    finIntroduction=`echo $finIntroduction | cut -d: -f1`
    finIntroduction=$(($finIntroduction+$debutIntrodution-1))

    (cat $f | tail -n +$ligneSuivante) | (while read line
    do
        # echo $line
        # if test `echo $line | egrep '^2$|^II$'`; then
            # echo "dans le if"
            # echo "$line"
            # echo ''

        # el
        if test `echo $line | grep '^[a-z]' `; then
                    # echo "OKOK" 
                    newDebut=`cat $f | (grep -n "$line" | head -1) | cut -d: -f1`
                    echo "newDebut = $newDebut"
                    finIntroduction=`cat $f | tail -n +$newDebut | (egrep -n '^2$|^II|^2\. [A-Z]|^II.[A-Z]|^2\.$|^2.[A-Z]|^.?2$' | head -1)`
                    echo "fin introdution : $finIntroduction"
                    finIntroduction=`echo $finIntroduction | cut -d: -f1`
                    finIntroduction=$(($finIntroduction+$newDebut-1))

                break
        else
            break
        fi
    done
    introdution=`cat $f | sed -n $debutIntrodution,$finIntroduction'p' | tr "\n" " "`
    if [ $2 = "-t" ]; then
    echo "Introduction :
    $introdution
" >> "$1/PARSE/${originalFilenames[$i]}.txt" 
    elif [ $2 = "-x" ]; then
        echo "<introdution>$introdution</introdution>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
    )
    i=$(($i+1))
done




i=0
# DISCUSSION
for f in $1/CONVERT/*.txt; do
    test=`cat $f | grep -c 'Discussion$'`
    if [[ $test != 0 ]]; then
        debut=`cat $f | (grep -n 'Discussion$' | head -1) | cut -d: -f1` # D[iI][sS][cC][uU][sS][sS][iI][oO][nN]
        fin=`cat $f | (grep -n 'C[oN][nN][cC][lL][uU][sS][iI][oO][nN]' | head -1) | cut -d: -f1`
        discussion=`cat $f | sed -n $(($debut+1)),$(($fin-1))'p'`
        # On ecrit dans le fichier
        if [ $2 = "-t" ]; then
            echo "Discussion :
        $discussion
    " >> "$1/PARSE/${originalFilenames[$i]}.txt"
        elif [ $2 = "-x" ]; then
            echo "<discussion>$discussion</discussion>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
        fi
    fi
done



i=0
# CONCLUSION
for f in $1/CONVERT/*.txt; do
    debut=`cat $f | (grep -n 'C[oN][nN][cC][lL][uU][sS][iI][oO][nN]' | head -1) | cut -d: -f1`
    if [[ `cat $f` =~ 'Acknowledgements' ]]; then
        fin=`cat $f | (grep -n 'Acknowledgement' | head -1) | cut -d: -f1`
    else
        fin=`cat $f | (grep -n 'R[eE][fF][eE][rR][eE][nN][cC][eE][sS]' | head -1) | cut -d: -f1`
    fi
    conclusion=`cat $f | sed -n $(($debut+1)),$(($fin-1))'p'`
    
    # On ecrit dans le fichier
    if [ $2 = "-t" ]; then
        echo "Conclusion :
    $conclusion
" >> "$1/PARSE/${originalFilenames[$i]}.txt"
    elif [ $2 = "-x" ]; then
        echo "<conclusion>$conclusion</conclusion>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
done



i=0
# REFERENCE
for f in $1/CONVERT/*.txt; do
    debut=`cat $f | (grep -n 'R[eE][fF][eE][rR][eE][nN][cC][eE][sS]' | head -1) | cut -d: -f1`
    debut=$(($debut+1))
    biblio=`cat $f | tail -n +$debut`

    # On ecrit dans le fichier
    if [ $2 = "-t" ]; then
        echo "Bibliotheque :
    $biblio
" >> "$1/PARSE/${originalFilenames[$i]}.txt"
    elif [ $2 = "-x" ]; then
        echo "<biblio>$biblio</biblio>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
done


i=0
for f in $1/CONVERT/*.txt; do
    if [ $2 = "-x" ]; then
        echo "</article>" >> "$1/PARSE/${originalFilenames[$i]}.xml"
    fi
done