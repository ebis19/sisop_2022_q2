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

COMPILADO=0
#FUNCIONES-----------------------------------------------

listar(){
	echo 'Archivo:'"$nombre_fichero", 'Evento:'"$event"
}

peso(){
	peso_archivo=$(du "$nombre_fichero")
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
	touch "$ruta_publicar/publicado"
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
	inotifywait -r -q -m -e  modify,delete,create,move "$ruta_monitoreo" --format "%w%f,%e" | while read file; do
        IFS=',' read -ra var <<< "$file"
        file_name=${var[0]}
        event=${var[1]}

	nombre_fichero=""

	generarNombreArchivo

	echo "$nombre_fichero $event"
	#for i in ${!acciones[@]}
	#	do
	#		if [[ ${acciones[i]} == $COMPILAR ]]
        #		then
         #       		compilar
#
 #       		elif [[ ${acciones[i]} == $PUBLICAR ]]
  #      		then
   #             		publicar
#
 #       		elif [[ ${acciones[i]} == $LISTAR ]]
  #      		then
   #             		listar
#
#			elif [[ ${acciones[i]} == $PESO ]]
#			then
#				peso
 #       		fi
#		done
#
	done
}

splitAcciones(){
	 IFS=',' read -r -a acciones <<< "$acciones"
}



#MAIN----------------------------------------------------

splitAcciones

monitorear















