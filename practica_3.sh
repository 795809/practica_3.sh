#!/bin/bash
#795809, Gracia Picó, Martina, T, 1, B
#800033, Ester de Val, Pilar, T, 1, B


accion=$1
fichero=$2
  
if [[ $EUID -eq 0 ]] 
then
    if test $# -ne 2 
    then
        echo "Numero incorrecto de parametros"
    else
        if [ "$accion" = "-a" ] 
	then
            for linea in $(cat "$fichero")
            do
                nom=$(echo "$linea" | cut -d "," -f 1)
                cont=$(echo "$linea" | cut -d "," -f 2)
                ncomp=$(echo "$linea" | cut -d "," -f 3)
            
                existe=0
         
                for  line in $(cat "/etc/passwd")
                 do
                  login=$(echo "$line" | cut -d ":" -f 1)
                  pas=$(echo "$line" | cut -d ":" -f 2)
                  uid=$(echo "$line" | cut -d ":" -f 3)
              
                    if [ "$login" = "$nom" ] 
		    then
                        existe=1
                        Uid=$uid
			            nom1=$nom
                    fi
                done
                if [ $existe = 1 ] 
		        then
                    echo "El usuario "$nom1" ya existe"
            	else
                    if [[ "$nom" == "" || "$cont" == "" || "$ncomp" == "" ]]
                    then
                    echo "Campo invalido"
                    exit 1
                    else

                                groupadd "$nom"
                                fecha=$(echo | date +"%d-%m-%Y" -d "next month")
                                useradd -m -c "$nom" -k /etc/skel -U -K UID_MIN=1815 -g "$nom" 
                                #-c es nombre completo , acontinuación tiene que ir el nombre completo
                                usermod -e $fecha
                                #fecha de expiración de la contraña
                                #echo '$nom:$cont' | chpasswd
                                usuario=$nom:$cont
                                echo "$usuario" > contraseñas.txt
                                chpasswd < contraseñas.txt
                                echo ""$ncomp" ha sido creado"
                    fi 
                fi
            done
        elif [ "$accion" = "-s" ] 
	    then
            mkdir -p /extra/backup
            for linea in $(cat "$fichero")
            do
                nom=$(echo "$linea" | cut -d "," -f 1)
                encontrado=0
                if [ "$nom" == "" ] 
		        then
                    echo "Campo invalido"
                    exit 1
		        fi
                for line in $(cat "/etc/passwd")
                do
                   login=$(echo "$line" | cut -d ":" -f 1)
                  if [ "$login" = "$nom" ]
                  then
                      encontrado=1
                      nom2=$(echo "$line" | cut -d ":" -f 6)
                  fi
                done
                   
                    if tar -cvzPf "$nom2".tar -C "$nom2"
                    then
                        mv "$nom2".tar ./extra/backup/
                        if [ $encontrado = 1 ] 
			            then 
                              userdel -rf "$nom"
                              #solo el nombre 
                        fi
                    fi
     		done
        else
            echo "Opcion invalida"
        fi
	fi
else
	echo "Este script necesita privilegios de administracion"
fi
