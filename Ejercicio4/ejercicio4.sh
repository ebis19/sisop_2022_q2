#!/bin/bash

COMENTARIO_SIMPLE="//"
COMENTARIO_MULTIPLE="/\*"
FIN_COMENTARIO_MULTIPLE="*/"

COMENTARIO_ABIERTO=1
COMENTARIO_CERRADO=0
EXT_CORRECTA=1
EXT_INCORRECTA=0

paramRutaNombre=$1
ruta=$2
paramExtNombre=$3
ext=$4

tipoComentario=$COMENTARIO_CERRADO

cantLineas=0
comentario=0
cantFicheros=0

#funciones
usage() {
        echo "AnalisisCodigoFuente\n"
        echo "Comandos permitidos y obligatorios:"
        echo "--ruta    Se coloca ruta (path) de los archivos con el c  digo fuente a analizar"
        echo "--ext     Se colocan las extensiones de los archivos a analizar, separadas por coma\n"
        echo "Ejemplo:\n"
        echo "AnalisisCodigoFuente --ruta home/usuario/proyecto1 --ext js,css,php"
}

validarInputs() {

        if [[ $paramRutaNombre == "-h" ]] || [[ $paramRutaNombre == "--help" ]] || [[ $paramRutaNombre == "-?" ]]
        then
                usage
                exit 0
        elif [[ $paramRutaNombre != "--ruta" ]]
        then
                echo "Parametro " $paramRutaNombre " desconocido"
                echo "--help para obtener ayuda"
                exit 1

        elif [[ $paramExtNombre != "--ext" ]]
        then
                echo "Parametro " $paramExtNombre " desconocido"
                echo "--help para obtener ayuda"
                exit 1
        fi
}


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
                        echo "ext correcta"
                        extension=$EXT_CORRECTA
                        break
                fi
        done
}


conteo() {
        (( cantLineas++ ))
        #COMENTARIOS CERRADOS   EJ. */ o ninguno
        if [[ $tipoComentario == $COMENTARIO_CERRADO ]]
        then
                if [[ $comienzoDeLinea == $COMENTARIO_SIMPLE ]]
                then
                                (( comentario++ ))
                elif [[ $comienzoDeLinea == $COMENTARIO_MULTIPLE ]]
                then
                        (( comentario++ ))
                        tipoComentario=$COMENTARIO_ABIERTO
                fi
        #COMENTARIOS ABIERTOS   Ej. /*
        else
                (( comentario++ ))

                if [[ $comienzoDeLinea == $FIN_COMENTARIO_MULTIPLE || $finDeLinea == $FIN_COMENTARIO_MULTIPLE ]]
                then
                        tipoComentario=$COMENTARIO_CERRADO
                fi
        fi
}

responsePorFichero() {
codigo=$((cantLineas - comentario))
porcentajeCodigo=$((codigo*100/cantLineas))
porcentajeComentario=$((100-porcentajeCodigo))
echo "Archivo: " $fichero
echo "Cantidad de lineas de codigo totales: " $codigo " con un porcentaje de: " $porcentajeCodigo"%"
echo "Cantidad de lineas de comentarios totales:  " $comentario "con un porcentaje de: " $porcentajeComentario"%"
}

leerFichero (){
while read -r linea
                do
                        comienzoDeLinea=${linea:0:2}
                        posFinalLinea=${#linea}-1
                        finDeLinea=${linea:$posFinalLinea-1:$posFinalLinea}

                        conteo
                 done < $fichero
}


#main
validarInputs

for fichero in $(ls $ruta)
do
       if [[ -r $fichero ]]
       then
                (( cantFicheros++ ))

                validarExtension
                if [[ $extension == $EXT_CORRECTA ]]
                then
                        (( cantidadFicheros++ ))
                        cantLineas=0
                        comentario=0
                        tipoComentario=$COMENTARIO_CERRADO
                        leerFichero
                        responsePorFichero
                 else
                        echo "El fichero " $fichero " no cuenta con la extension a analizar"
                fi
        else
                echo "NO TIENE PERMISOS PARA ESTE FICHERO: " $fichero
        fi
done
echo "Cantidad de archivos analizados: " $cantFicheros
exit 1