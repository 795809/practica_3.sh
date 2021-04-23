
#795809, Gracia Picó, Martina, T, 1, B
#800033, Ester de Val, Pilar, T, 1, B
#!/bin/bash

accion=$1
fichero=$2
  
if[[ $EUID -ne 0 ]] then
    echo "Este script necesita privilegios de administracion"
    exit 1
else
    if test $# -ne 2 then
        echo "Numero incorrecto de parametros"
    else
        if [ $accion = "-a" ] then
            for linea in $(more "$fichero")
            do
                nom=$(echo "$linea" | cut -d "," -f 1)
                cont=$(echo "$linea" | cut -d "," -f 2)
                ncomp=$(echo "$linea" | cut -d "," -f 3)
            
                existe=false
              
                for  line in $(more "/etc/passwd")
                 do
                  login=$(echo "$line" | cut -d "," -f 1)
                  pas=$(echo "$line" | cut -d "," -f 2)
                  uid=$(echo "$line" | cut -d "," -f 3)
              
                    if [ $login = $nom ] then
                        existe=true
                        Uid=$uid
                    fi
                done
                if existe -eq true then
                    echo "El usuario $Uid ya existe"
                else
                    if [[ "$nom" == "" || "$cont" == "" || "$ncomp" == "" ] then
                        echo "Campo invalido" 
                        exit 1
                    else
                        groupadd $nom
                        fecha=$(echo | date +"%d-%m%Y" -d "next month")
                        useradd -m -K UID_MIN=1815 -e $fecha -g $nom $nom
                        usuario=$nom:$cont
                        echo $usuario > contraseñas.txt
                        chpasswd < contraseñas.txt
                        echo " $ncomp ha sido creado"
                    fi
                fi
            done
        elif [ $accion = "-s" ] then
            mkdir -p /extra/backup
            for linea in $(more "$fichero")
            do
                nom=$(echo "$linea" | cut -d "," -f 1)
                encontrado=false
                if [ "$nom" == "" ] then
                    echo "Campo invalido"
                    exit 1
                for line in $(more "/etc/passwd")
                do
                   login=$(echo "$line" | cut -d "," -f 1)
                  if [ $login = $nom ]
                  then
                      encontrado=true
                  fi
                done
                    DATE=$(echo | date +%Y-%m-%d-%H-%M-%S)
                    BACKUP_DIR="/extra/backup /backup"
                    SOURCE="$HOME/$nom/"
                    if tar -cvzPf $nom.tar -C /home/$nom/ 
                    then
                        mv $nom.tar /extra/backup
                        if encontrado -eq true then 
                              userdel -f home/$nom
                        fi
                    fi
            done
        else
            echo "Opcion invalida"
        fi
    fi
fi
