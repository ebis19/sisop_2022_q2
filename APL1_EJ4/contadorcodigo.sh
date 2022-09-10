#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: contadorcodigo.sh          #
# APL 1						#
# Ejercicio 4					#
# Integrantes:                                  #
# Molina Lara			DNI: 40187938   #
# Lopez Julian			DNI: 39712927	#
# Gorbolino Tamara              DNI: 41668847   #
# Biscaia Elias			DNI: 40078823	#
# Amelia Colque			DNI: 34095247	#
# Entrega                                  	#
#-----------------------------------------------#

COMENTARIO_SIMPLE="//"
COMENTARIO_MULTIPLE="/\*"
FIN_COMENTARIO_MULTIPLE="*/"

COMENTARIO_ABIERTO=1
COMENTARIO_CERRADO=0
EXT_CORRECTA=1
EXT_INCORRECTA=0

tipoComentario=$COMENTARIO_CERRADO

cantLineas=0
comentario=0
cantFicheros=0
codigoaEntreComentario=0
codigoaEntreComentarioTotal=0

cantLineasTotales=0
comentariosTotales=0

#----------------------------

#Validacion de parametros
#funciones
usage() {
        echo "contador de codigo"
        echo "Comandos permitidos y obligatorios:"
        echo "--ruta    Se coloca ruta (path) de los archivos con el codigo fuente a analizar"
        echo "--ext     Se colocan las extensiones de los archivos a analizar, separadas por coma"
        echo "Ejemplo:\n"
        echo "./contadorcodigo.sh --ruta home/usuario/proyecto1 --ext js,css,php"

	exit 0
}


#----------------------------

#Validacion de parametros
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


PARSED_ARGUMENTS=$(getopt -o '' --long "ruta:,ext:" -- "$@")
        eval set -- "$PARSED_ARGUMENTS"

        while true
        do
                case "$1" in
                --ruta ) ruta="$2" ; shift; shift ;;
                --ext ) ext="$2"; shift; shift ;;
                -- ) shift ; break;;
                * ) echo "Parametros no validas" ; break ;;
                esac
        done

validarExtension() {
        extension=$EXT_INCORRECTA

        #separo las extensiones
        IFS=',' read -r -a extensiones <<< "$ext"

        for i in ${!extensiones[@]}
        do
                extensionActual=${extensiones[i]}
                posFinalFichero=${#fichero}-1
                extFichero=${fichero:$posFinalFichero-${#extensionActual}+1:$posFinalFichero}

                if [[ $extFichero == ${extensionActual} ]]
                then
                        extension=$EXT_CORRECTA
                        break
                fi
        done
}


conteo() {
        (( cantLineas++ ))
	(( cantLineasTotales++ ))
        #COMENTARIOS CERRADOS   EJ. */ o ninguno
        if [[ $tipoComentario == $COMENTARIO_CERRADO ]]
        then
                if [[ $comienzoDeLinea == $COMENTARIO_SIMPLE ]]
                then
                                (( comentario++ ))
				(( comentariosTotales++ ))
		elif [[ $comienzoDeLinea == $COMENTARIO_MULTIPLE ]]
                then
                        (( comentario++ ))
			(( comentariosTotales++ ))
                        if [[ $finDeLinea == $FIN_COMENTARIO_MULTIPLE ]] #valido si el comentario multiple cierra en la misma linea
                        then
                                tipoComentario=$COMENTARIO_CERRADO
                        else
				tipoComentario=$COMENTARIO_ABIERTO
			fi

		#COMENTARIO DE TIPO ...//....
		elif [[ "$linea" == *"$COMENTARIO_SIMPLE"* ]]
		then
			(( comentario++ ))
			(( comentariosTotales++ ))
			(( codigoaEntreComentario++ ))
			(( codigoaEntreComentarioTotal++ ))

		#COMENTARIO DE TIPO ..../*....*/
		elif [[ "$linea" == *"$COMENTARIO_MULTIPLE"* ]]
		then
			(( comentario++ ))
                        (( comentariosTotales++ ))
                        (( codigoaEntreComentario++ ))
                        (( codigoaEntreComentarioTotal++ ))

			#COMENTARRIO QUE NO CIERRA EN LA MISMA LINEA EJ. ...../*.......
			if [[ "$linea" != *"$FIN_COMENTARIO_MULTIPLE"* ]]
			then
				tipoComentario=$COMENTARIO_ABIERTO
			fi
		fi
        #COMENTARIOS ABIERTOS   Ej. /*
        else
                (( comentario++ ))
		(( comentariosTotales++ ))

                if [[ $comienzoDeLinea == $FIN_COMENTARIO_MULTIPLE || $finDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                then
                        tipoComentario=$COMENTARIO_CERRADO

		elif [[ "$linea" == *"$FIN_COMENTARIO_MULTIPLE"* ]]
		then
			tipoComentario=$COMENTARIO_CERRADO
			(( codigoaEntreComentario++ ))
                        (( codigoaEntreComentarioTotal++ ))
                fi
        fi
}

responsePorFichero() {
codigo=$((cantLineas - comentario + codigoaEntreComentario))
porcentajeCodigo=$((codigo*100/cantLineas))
porcentajeComentario=$((100-porcentajeCodigo))
echo "------------------------------------------------"
echo "Archivo: " "$fichero"
echo "Cantidad de lineas de codigo: " $codigo " con un porcentaje de: " $porcentajeCodigo"%"
echo "Cantidad de lineas de comentarios:  " $comentario "con un porcentaje de: " $porcentajeComentario"%"
echo "------------------------------------------------"
}

leerFichero (){
while read -r linea
                do
                        comienzoDeLinea=${linea:0:2}
                        posFinalLinea=${#linea}
                        finDeLinea=${linea:$posFinalLinea-1:$posFinalLinea}

                        conteo
                 done < "$fichero"
}


#main
#validarInputs


for filename in $(ls "$ruta")
do
	fichero="$ruta"/"$filename"

       if [[ -r "$fichero" ]]
       then
                validarExtension
                if [[ $extension == $EXT_CORRECTA ]]
                then
                       (( cantidadFicheros++ ))
                        cantLineas=0
                        comentario=0
			codigoaEntreComentario=0
                        tipoComentario=$COMENTARIO_CERRADO
                        leerFichero
                        responsePorFichero
                fi
        else
       	       echo "NO TIENE PERMISOS PARA ESTE FICHERO: " "$fichero"
        fi
done
codigoTotal=$((cantLineasTotales - comentariosTotales + codigoaEntreComentarioTotal))
porcentajeCodigoTotal=$((codigoTotal*100/cantLineasTotales))
porcentajeComentarioTotal=$((100-porcentajeCodigoTotal))
echo "------------------------------------------------"
echo "TOTALES"
echo "Cantidad de archivos analizados: " $cantidadFicheros
echo "Cantidad de lineas de codigo: " $codigoTotal " con un porcentaje de: " $porcentajeCodigoTotal"%"
echo "Cantidad de comentarios" $comentariosTotales " con un porcentaje de: " $porcentajeComentarioTotal"%"
exit 1

