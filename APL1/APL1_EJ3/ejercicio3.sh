#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: ej3.sh                     #
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
    echo "Usage: $0 -c <path> -a <action> -s <path>"
    echo "  -c <path>  Path to watch"
    echo "  -a <action> Action to perform when a change is detected"
    echo "  -s <path>  Path to publish"
    echo "  -h  Show this help"
    echo "The accions can be : publish, compilar, listar y peso."
    echo "Important cosider that the path to watch must be a directory"
    echo "and the path to publish must be a directory."
    echo "To Publish action needs a compilar action"
    echo "Example : $0 -c ./dir -a compilar,publish"
    echo "Example 2 : $0 -c ./dir -a listar,peso"
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
		if [ $# -eq 1 ]
		then
                	usage;
                	exit 0;
        	else
                	echo "Cantidad de parametros incorrectos, para obtener mas ayuda ejecutar el comando -h, --help o -? seguido de $0";
                	exit 1;
		fi
        fi
	elif [[ $# < 4 ]]
	then
		echo "Cantidad de parametros incorrectos, para obtener mas ayuda ejecutar el comando -h, --help o -? seguido de $0";
        	exit 1;
fi

PARSED_ARGUMENTS=$(getopt -o "s:c:a:h:?" -l "" -a -- "$@")
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

#CONSTANTES----------------------------------------------

DEMONIO_ACTIVADO=0

LISTAR="listar"
PESO="peso"
COMPILAR="compilar"
PUBLICAR="publicar"

#FUNCIONES-----------------------------------------------

listar(){
	echo "LISTAR"
}

peso(){
	echo "PESO"
}

compilar(){
	echo "COMPILAR"
}

publicar(){
	echo "PUBLICAR"
}


monitoreo(){
	echo "MONITOREO"
}

splitAcciones(){
	 IFS=',' read -r -a acciones <<< "$acciones"
}
#MAIN----------------------------------------------------



splitAcciones

for i in ${!acciones[@]}
do
	if [[ ${acciones[i]} == $COMPILAR ]]
	then
        	compilar

	elif [[ ${acciones[i]} == $PUBLICAR ]]
	then
        	publicar

	elif [[ ${acciones[i]} == $LISTAR || ${acciones[i]} == $PESO ]]
	then
		$DEMONIO_ACTIVADO=1
	fi
done



















