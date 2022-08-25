#!/bin/bash

COMENTARIO_SIMPLE="//"
COMENTARIO_MULTIPLE="/\*"
FIN_COMENTARIO_MULTIPLE="*/"

COMENTARIO_ABIERTO=1
COMENTARIO_CERRADO=0

ruta=$1
ext=$2

declare -A ficheroLineasTotales
declare -A ficheroComentariosSimples
declare -A fileMultiComments

comentario=$COMENTARIO_CERRADO


leerFichero (){
while read -r linea
                do
                        (( ficheroLineasTotales[$fichero]++ ))

                        comienzoDeLinea=${linea:0:2}
                        posFinalLinea=${#linea}-1
                        finDeLinea=${linea:$posFinalLinea-1:$posFinalLinea}

                        #COMENTARIOS CERRADOS

                         if [[ $comentario == $COMENTARIO_CERRADO ]]
                         then
                                if [[ $comienzoDeLinea == $COMENTARIO_SIMPLE ]]
                                then
                                        (( ficheroComentariosSimples[$fichero]++ ))
                                else
                                        if [[ $comienzoDeLinea == $COMENTARIO_MULTIPLE ]]
                                        then
                                                (( fileMultiComments[$fichero]++ ))
                                                 comentario=$COMENTARIO_ABIERTO
                                        fi
                                fi
                         else   #COMENTARIOS ABIERTOS
                                (( fileMultiComments[$fichero]++ ))
                                if [[ $comienzoDeLinea == $FIN_COMENTARIO_MULTIPLE || $finDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                                then
                                        comentario=$COMENTARIO_CERRADO
                                fi

                          fi

                 done < $fichero


 }


comentarios (){
echo "COMENTARIOS SIMPLES:"
for i in ${!ficheroComentariosSimples[@]}
do
        echo ${ficheroComentariosSimples[$i]}
done
echo "COMENTARIOS MULTIPLES:"
for i in ${!fileMultiComments[@]}
do
        echo ${fileMultiComments[$i]}
done
}
for fichero in $(ls $ruta)
do
        if [ -r $fichero ]
        then
                echo "tiene permisos de lectura para este fichero: " $fichero
                leerFichero
                comentarios
        else
                echo "NO TIENE PERMISOS PARA ESTE FICHERO: " $fichero
        fi
done