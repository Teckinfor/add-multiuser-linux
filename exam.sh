#!/bin/bash

exit=0
liste="listing.txt"
delimiteur=";"

if [[ -z $1 ]];then
	echo "Aide : Voici les options possibles :"
	echo "------------------------------------"
	echo  
	echo "-f permet de préciser l\'emplacement du fichier à utiliser, si l\'option n\'est pas utilisée, le script utilise le fichier /home/user/listing.txt."
	echo "-d permet de choisir un autre séparateur que le ;."
	echo "-a permet d\'ajouter de nouveaux user/group/password au fichier listing.txt."
	echo "-e le script crée les utilisateurs sur le système"
	echo
	echo "Remarque : Pour une bonne utilisation du script, les options doivent être entrées dans l'ordre f, d, a, e"

else
	while getopts "f:d:ae" option
	do
		case $option in

			f)
			if [[ -z $OPTARG ]]; then
				exit=1
				exit $exit
			else
				liste=$OPTARG
				echo "Liste choisie :" $liste
			fi
			;;

			d)
			if [[ -z $OPTARG ]]; then
				exit=1
				exit $exit
			else
				delimiteur=$OPTARG
				echo "Le nouveau delimiteur est:" $delimiteur
			fi
			;;

			a)
				echo "Ajout d'un nouvel utilisateur :"
				echo "-------------------------------"
				echo
				echo "Nouveau username:"
				read user
				while grep -q $user $liste
				do
					echo "Utilisateur déjà existant"
					echo "Nouveau username"
					read user
				done
				echo "Nouveau groupe:"
				read group
				echo "Mot de passe:"
				read -s pass
				echo $user$delimiteur$group$delimiteur$pass >> $liste
				echo
				echo "Affichage du contenu de" $liste
				echo "-----------------------------------"
				cat $liste
			;;

			e)
				cat $liste | while read line; do
					user=$(echo $line | cut -d $delimiteur -f 1)
					group=$(echo $line | cut -d $delimiteur -f 2)
					pass=$(echo $line | cut -d $delimiteur -f 3)
					pass=$(mkpasswd --method=SHA-512 $pass 2> /dev/null)
					if [[ $? == "127" ]]; then
						echo "Veuillez installer mkpasswd pour crypter vos mots de passe"
						pass=$(echo $line | cut -d $delimiteur -f 3)
					fi
					groupadd $group 2> /dev/null
					if [[ $? == "9" ]]; then
						echo "Groupe" $group  "déjà existant"
					else
						echo "Création du groupe" $group
					fi
					useradd -g $group -p $pass -s /bin/bash $user 2> /dev/null
					if [[ $? == "9" ]]; then
						echo "Utilisateur" $user  "déjà existant"
					else
						echo "Création de l'utilisateur" $user
					fi
				done
			;;

			\?)exit=2;;

		esac

	done
fi

exit $exit
