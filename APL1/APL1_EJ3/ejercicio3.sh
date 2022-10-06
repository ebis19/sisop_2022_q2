#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: ejercicio3.sh              #
# APL 1                                         #
# Ejercicio 3                                   #
# Integrantes:                                  #
# Molina Lara                     DNI: 40187938 #
# Lopez Julian                    DNI: 39712927 #
# Gorbolino Tamara                DNI: 41668847 #
# Biscaia Elias                   DNI: 40078823 #
# Amelia Colque                   DNI: 34095247 #
# Nro entrega: 3                                #
#-----------------------------------------------#


# Ejercicio 3
# Path: ej3.sh
# -c  path
# -a lista de acciones
# -s directorio de publicacion
# ejemplo ./ej3.sh -c ./dir -a publish
#notficar cambios de un detreminado directorio con inotifywait

usage() {
    echo "------------------------AYUDA------------------------------"
    echo "Este script simula un sistema de integración continua, ejecutando"
    echo "una serie de acciones(listar, peso, compilar, publicar) cada vez que se detecta un cambio en un directorio"
    echo "    "
    echo "Parametros que recibe: "
    echo "      -c <path>  ruta del directorio a monitorear"
    echo "      -a <action> acciones separadas con coma a ejecutar ante cambios en el directorio"
    echo "      -s <path>  ruta del directorio utilizado por la acción publicar"
    echo "      -h o --help o -?  muestra la ayuda"
    echo "      "
    echo "Ejemplo:"
    echo "1) Consultar la ayuda: "
    echo "      ./Ejercicio6.sh -h"
    echo "      ./Ejercicio6.sh --help"
    echo "      ./Ejercicio6.sh -?"
    echo "     "
    echo "2) Utilizar la accion publicar: "
    echo "      $0 -c repo -a listar,compilar,publicar -s salidas/publicar"
    echo "     "
    echo "3) No utilizar la opcion publicar: "
    echo "      $0 -c ../repo -a listar,peso"
    echo "   "
    echo "Aclaracion: tener instalado inotify-tools"
    exit 1
}


#VALIDACION DE PARAMETROS---------------------------
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    exit 1
fi


if [ $# -eq 1 ]
then
        if [[ $1 == "-h" ]] || [[ $1 == "--help" ]] || [[ $1 == "-?" ]]
        then

                usage;
                exit 0;
        else
                echo "Cantidad de parametros incorrectos, para obtener mas ayuda ejecutar el comando -h, --help o -? seguido de $0";
                exit 1;
        fi
	elif [[ $# < 4 ]]
	then
		echo "Cantidad de parametros incorrectos, para obtener mas ayuda ejecutar el comando -h, --help o -? seguido de $0";
        	exit 1;
fi

PARSED_ARGUMENTS=$(getopt -o "s:c:a" -l "" -a -- "$@")
        eval set -- "$PARSED_ARGUMENTS"
        while true
        do
                case "$1" in
                -c ) ruta_monitoreo="$2" ; shift; shift ;;
                -a ) acciones="$2"; shift; shift ;;
 		-s ) ruta_publicar="$2"; shift; shift ;;
                -- ) shift ; break;;
                * ) echo "Parametros no validas" ; break ;;
                esac
        done

#TODO: VALIDAR ARGUMENTOS

#CONSTANTES----------------------------------------------

DEMONIO_ACTIVADO=0

LISTAR="listar"
PESO="peso"
COMPILAR="compilar"
PUBLICAR="publicar"

COMPILADO=0
#FUNCIONES-----------------------------------------------

listar(){
	echo 'Archivo:'"$nombre_fichero", 'Evento:'"$event"
}

peso(){
	peso_archivo=$(du -h "$nombre_fichero") #Suele dar 4K porque es espacio en disco y el minimo que se le da es eso.
	echo  "Peso: $peso_archivo"
}

compilar(){

if ! [ -d "./bin" ] ; then
    mkdir "bin"
fi
if  [ -f "bin/compilado" ] ; then
    rm  "bin/compilado"
fi

	IFS=$'\n';

	for arch in $(find "$ruta_monitoreo"); do
        	if [ -f "$arch" ]; then
            		cat "$arch" >> "bin/compilado"
        	fi
    	done

	COMPILADO=1
}

publicar(){

if ! [ -d "$ruta_publicar" ] ; then
	mkdir "$ruta_publicar"
fi

if [ -f "bin/compilado" ]; then
        cp "bin/compilado" "$ruta_publicar/publicado"
fi

}

#Esta funcion se necesita porque la ruta del archivo dada por el inotify llega con puntos intermedios y una extension .swp.
#necesitando formatear el nombre al correcto para enviarlas correctamente para las acciones que las necesiten
generarNombreArchivo(){
 	posFinalFile=`expr ${#file_name} - 1`

	if [[ $posFinalFile -gt 4 ]] #para create, modify, delete se le agrega la extension .swp al archivo, pero no el  momento del guardado. Verificamos si lo tiene
	then
		tieneswp=${file_name:$posFinalFile-3:$posFinalFile}
	else
		tieneswp=""
	fi

	if [[ "$tieneswp" == ".swp" ]]				#En caso de que la ruta del archivo contenga la extension .swp se la sacamos
	then
       		fichero=${file_name:0:$posFinalFile-3}
	else
		fichero="$file_name"
	fi

        posfinalfichero=${#fichero}-1
        ficheroExt=${fichero:posfinalfichero-3:1}

       	tieneExtension=0
        if [[ $ficheroExt == '.' ]]			#Verifico que el archivo tenga una extension ejemplo nombre.text para tenerlo en cuenta en la concatenacion que forma la ruta/nombre
        then
        	tieneExtension=1
      	fi

	punto=${fichero:0:1}

	if [[ $punto == '.' ]]				#verifico que la ruta comience con ./ para escribir el punto al principio de la concatenacion
	then
		nombre_fichero+='.'
	fi

      	IFS='.' read -ra split_fichero <<< "$fichero"

      	ultimo=`expr ${#split_fichero[@]} - 1`

      	for i in ${!split_fichero[@]}
      	do
        	if [[ $i == $ultimo && $tieneExtension == 1 ]]
                then
                	nombre_fichero+=".${split_fichero[i]}"
                else
                        nombre_fichero+="${split_fichero[i]}"
                fi
       	done
}

monitorear(){
	inotifywait -m -e modify,delete,create,move "$ruta_monitoreo" --format "%w%f,%e" | while read file; do
	IFS=',' read -ra var <<< "$file"
        file_name=${var[0]}
        event=${var[1]}
	nombre_fichero=""

	generarNombreArchivo

	COMPILADO=0

	for i in ${!acciones[@]}
		do
			if [[ ${acciones[i]} == $COMPILAR && $COMPILADO == 0 ]]	#si en el array de acciones la publicacion esta antes que la compilacion, se compilara antes de publicar, por ende
        		then							#con COMPILADO == 0 nos aseguramos que no se compile dos veces en el mismo evento
        	       		compilar

	       		elif [[ ${acciones[i]} == $PUBLICAR ]]
        		then
				if [[ $COMPILADO == 0 ]]			#Si no se compilo, compilamos
				then
					compilar
				fi

                		publicar

        		elif [[ ${acciones[i]} == $LISTAR ]]
        		then
                		listar

			elif [[ ${acciones[i]} == $PESO && "$event" != "DELETE" ]] #Si se borra el archivo no tiene peso
			then
				peso
        		fi
		done

	done

}

splitAcciones(){
	 IFS=',' read -r -a acciones <<< "$acciones"
}




#MAIN----------------------------------------------------

splitAcciones

#Validacion de publicar solo si esta la accion compilar
isCompilar=0
isPublicar=0

cant_compilado=0
cant_publicado=0
cant_listado=0
cant_peso=0
for accion  in ${acciones[@]}
do
	#valido si la accion ingresada es opcion permitida
	if [[ $accion != $COMPILAR && $accion != $PUBLICAR && $accion != $PESO && $accion != $LISTAR  ]]
        then
		echo "La accion $accion no esta permitida"
		exit 1
	fi

	#valido si accion compilar esta repetida
	if [[ $accion == $COMPILAR ]]
	then
		(( cant_compilado++ ))
		isCompilar=1
		if [[ $cant_compilado > 1 ]]
		then
			echo "La accion compilar esta repetida"
			exit 1
		fi
	fi

	#valido si la accion publicar esta repetida
	if [[ $accion == $PUBLICAR ]]
        then
                isPublicar=1
		(( cant_publicado++ ))
                if [[ $cant_publicado > 1 ]]
                then
                        echo "La accion publicar esta repetida"
                        exit 1
                fi
        fi

	#valido si la accion peso esta repetida
	if [[ $accion == $PESO ]]
        then
                (( cant_peso++ ))
                if [[ $cant_peso > 1 ]]
                then
                        echo "La accion peso esta repetida"
                        exit 1
                fi
        fi

	#valido si la accion listar esta repetida
	if [[ $accion == $LISTAR ]]
        then
                (( cant_listado++ ))
                if [[ $cant_listado > 1 ]]
                then
                        echo "La accion listar esta repetida"
                        exit 1
                fi
        fi
done

#VALIDO SI QUIERE PUBLICAR SIN COMPILAR
if [[ $isPublicar == 1 && $isCompilar == 0  ]]
then
     echo "No se puede publicar sin compilar"
     exit 1
fi

#VALIDO SI QUIERE PUBLICAR SIN UNA CARPETA PARA PUBLICAR
if [[ $isPublicar == 1 && -z "$ruta_publicar" ]]
then
     echo "No puedo publicar si no existe una ruta para publicar"
     exit 1
fi

monitorear















