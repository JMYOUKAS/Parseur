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

for f in $1/*.pdf
do
    #echo $f
    nom=$(basename "$f" .pdf)
    #echo $nom
    chemin="$1/CONVERT/$nom.txt"
    pdftotext "$f" "$chemin"
   # mv $chemin ${bis// /_}
    
done

for f in $1/CONVERT/*.txt
do
    nouveau_nom=`echo $f | tr " " "_"`
    mv -i "$f" $nouveau_nom
done


# RECUPER L'ABSTRACt
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
    abstract=`cat $f | sed -n $debut,$finSansIntroduction'p'`
    #abstract2=`echo $abstract | tr " " "\n"`
      
    #echo $abstract2
done

# A FAIRE DEMAIN (Aujourd'hui pour vous du coup :thinking:)

for f in $1/CONVERT/*.txt
do
    echo ''
    echo "Nouveau document"
    titre=''
    cat $f | while read line; 
    do
 
    if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ 'www' ]] || [[ "$line" =~ '@' ]]; then
        if test -z "$titre"; then
           continue
        else
            echo "VOICI LE TITRE COMPLET"
            echo "$titre"
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
                    echo "VOICI LE TITRE COMPLET"
                    echo "$titre"
                    break
                #Sinon               
                else 
                    #RAJOUTER LA VERIFICATION DES VIRGULES TOUTS LES DEUX MOTS (Juste sur le premier c'est suffisant)
                    #echo "Le titre"
                    #echo "$titre"
                    #echo "$line"
                    titre="$titre $line"
                    #echo "$titre"
                fi
            fi
        fi
    fi
    done
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
     




#for f in $1/CONVERT/*.txt
#do
 #   for line in $(cat $f)
 #   do
        #Si la ligne contient une date ou un mail ou vide
            #Ne rien faire
           
        #Aide : if [[$line == *[0-9]* ]] // verifie si ya un chiffre


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
  #  done        
#done
