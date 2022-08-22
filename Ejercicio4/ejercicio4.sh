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

for fichero in $(ls $1)
do

        if [ -r $fichero ]
        then
                echo "tiene permisos de lectura para este fichero: " $fichero

                while read -r linea
                do
                        (( ficheroLineasTotales[$fichero]++ ))

                        comienzoDeLinea=${linea:0:2}
                        posFinalLinea=${#linea}-1
                        finDeLinea=${linea:$posFinalLinea-1:$posFinalLinea}

                        #COMENTARIO SIMPLE
                        if [[ $comienzoDeLinea == $COMENTARIO_SIMPLE ]]
                        then
                                if [[ $comentario == $COMENTARIO_CERRADO ]]
                                then
                                        (( ficheroComentariosSimples[$fichero]++ ))
                                fi
                        fi

                        #COMENTARIO MULTIPLE

                        if [[ $comienzoDeLinea == $COMENTARIO_MULTIPLE ]]
                        then
                            echo "comienzo multiple -> " $comienzoDeLinea
                                if [[ $comentario == $COMENTARIO_CERRADO ]]
                                then
                                        comentario=$COMENTARIO_ABIERTO
                                        (( fileMultiComments[$fichero]++ ))
                                fi
                        else

                                if [[ $comienzoDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                                then
                                        if [[ $comentario == $COMENTARIO_ABIERTO ]]
                                        then
                                                comentario=$COMENTARIO_CERRADO
                                                (( fileMultiComments[$fichero]++ ))
                                        fi
                                else

                                if [[ $comienzoDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                                then
                                        if [[ $comentario == $COMENTARIO_ABIERTO ]]
                                        then
                                                comentario=$COMENTARIO_CERRADO
                                                (( fileMultiComments[$fichero]++ ))
                                        fi
                                else

                                        if [[ $finDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                                        then
                                                if [[ $comentario == $COMENTARIO_ABIERTO ]]
                                                then
                                                        comentario=$COMENTARIO_CERRADO
                                                        (( fileMultiComments[$fichero]++ ))
                                                fi
                                        else
                                                if [[ $comentario == $COMENTARIO_ABIERTO ]]
                                                then
                                                        (( fileMultiComments[$fichero]++ ))
                                                fi
                                        fi
                                fi
                        fi

                done < $fichero

        else
                echo "NO TIENE PERMISOS PARA ESTE FICHERO: " $fichero
        fi
done

echo "COMENTARIOS SIMPLES:"

for i in ${!ficheroComentariosSimples[@]}
do
        echo $i ${ficheroComentariosSimples[$i]}
done

echo "COMENTARIOS MULTIPLES:"
for i in ${!fileMultiComments[@]}
do
        echo $i ${fileMultiComments[$i]}
done