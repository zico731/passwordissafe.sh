#!/bin/bash
# Ce script teste les mots passe comrompu selon: 
# https://api.pwnedpasswords.com/range/
# requirements:
# - config.ini contenant : url de l'api, driver,fichier_db
# - users-database.csv contenant : login,sha1_password
# 
# OUTPUT :
#
# login       pwned     count
# ----------  --------  --------
# toto        False     0
# tata        True      37359195
# tutu        True      73586
# nkarolak    False     0
# monuser     False     0 


# test la connectivité
ping -q -c1 -W1 8.8.8.8 > /dev/null	|| (echo "non connecté" ; exit 1)


# test la presence de config.ini
if [ -f 'config.ini' ]
then
# on parse les données qui nous interessent
	url=$(cat config.ini|grep "^url"| cut -d'=' -f2)
	driver=$(cat config.ini|grep "^driver"| cut -d'=' -f2|xargs)
	fichier=$(cat config.ini|grep "^path"| cut -d'=' -f2|xargs)
echo $url
else
# on sort du programme en cas où config.ini est manquant
	echo -e "\nLe fichier config.ini est manquant !\n"
exit 2
fi

# test la presence du fichier de base de données
if [ -f $fichier ]
then
        # le fichier existe
		echo "login;pwned;count" > resultat.txt
		#printf "%-10s%-8s%+8s\n" 'login' 'pwned' 'count' > resultat.txt
		echo '----------;--------;--------' >> resultat.txt
        # affectation des variables selon chaque champs de la ligne
		while IFS=";" read login password
        do
                ligne=""
				pwnded=True
				
				# on extrait les 5 premiers caracteres du sha1password
				pre=${password:0:5}
				
				# on ne ligne pas l'entete correspont aux nom des champs
				if [ $login != "login" ]; then  
					
					
					suf=${password:5}
					#suf=${suf// /}
					
					#on capture le nombre de compromissions
					count=$(curl -s $url$pre| grep -i $suf|cut -d':' -f2)
					
					if [ -z "$count" ]; then
						count='0'
						pwnded=False
						
					fi
					
					ligne=$login";"$pwnded";"$count
					echo -e "$ligne" >> resultat.txt
				fi
					
        done <$fichier

else
        #le fichier n'existe pas
        echo -e "\nLE NOM DU FICHIER $fichier N'EXISTE PAS! \n"
		exit 3
fi

# on converti les fins de ligne en Unix
cat resultat.txt|sed 's/\r//g' > resultat.txt
echo

# mise en page
cat resultat.txt|column -tns';'
echo
