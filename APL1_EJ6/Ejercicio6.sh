#!/bin/bash

# ******************************************************* #
#                      Ejercicio 6                        #
#                                                         #
# ******************************************************* #

ayuda(){
    echo "************************************************"
    echo " Este script emula una papelera de reciclaje.   "
    echo " Al borrar un archivo se tiene la posibilidad   "
    echo " de recuperarlo en un futuro.                   "
    echo " La papelera de reciclaje será un archivo zip   "
    echo " y la misma se guarda en el home del usuario    "
    echo " que ejecuta el script.                         "
    echo "                                                "
    echo " Ejemplo:                                       "
    echo "  1) Consultar la ayuda:                        "
    echo "      ./Ejercicio6.sh -h                        "
    echo "      ./Ejercicio6.sh --help                    "
    echo "      ./Ejercicio6.sh -?                        "
    echo "                                                "
    echo "  2) Listar contenido de papelera               "
    echo "      ./Ejercicio6.sh --listar                  "
    echo "                                                "  
    echo "  3) Recuperar archivo de papelera              "
    echo "      ./Ejercicio6.sh --recuperar archivo       "
    echo "                                                "
    echo "  4) Vaciar contenido de papelera               "
    echo "      ./Ejercicio6.sh --vaciar                  "
    echo "                                                "
    echo "  5) Eliminar archivo (se envía a la papelera)  "
    echo "      ./Ejercicio6.sh --eliminar archivo        "
    echo "                                                "  
    echo "  6) Borrar archivo (de la papelera)            "  
    echo "     ./Ejercicio6.sh --borrar archivo           "
    echo "                                                "
    echo "                                                "        
    echo "************************************************"
}

# ********** #
# Funciones  #
# ********** #

listar(){
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existe archivo a listar"
        exit 1
    fi

    if [ $(tar -tf "$papelera" | wc -c) -eq 0 ];
    then
        echo "Papelera se encuentra vacía"
        exit 1
    fi

    IFS=$'\n'
    for archivo in $(realpath $(tar -tf "$papelera"))
    do
        rutaArchivo=$(dirname "$archivo")
        nombreArchivo=$(basename "$archivo")
        echo "$nombreArchivo $rutaArchivo"
    done
}

recuperar(){
    archivoParaRecuperar="$1"
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existen archivos a recuperar"
        exit 1
    fi
    if [ "$archivoParaRecuperar" == "" ];
    then
        echo "Parámetro archivo a recuperar sin informar"
        exit 1
    fi

    contadorArchivosIguales=0
    archivosIguales=""
    declare -a arrayArchivos

    IFS=$'\n'
    for archivo in $(realpath $(tar -tf "$papelera"))
    do
        rutaArchivo=$(dirname "$archivo")
        nombreArchivo=$(basename "$archivo")
        if [ "$nombreArchivo" == "$archivoParaRecuperar" ];
        then
            let contadorArchivosIguales=contadorArchivosIguales+1
            archivosIguales="$archivosIguales$contadorArchivosIguales - $nombreArchivo $rutaArchivo;"
            arrayArchivos[$contadorArchivosIguales]="$archivo"
        fi
    done

    if [ "$contadorArchivosIguales" -eq 0 ];
    then
        echo "No existe el archivo en la papelera"
        exit 1
    else
        if [ "$contadorArchivosIguales" -eq 1 ];
        then
            tar -xvf "$papelera" "$archivoParaRecuperar" 1> /dev/null 
            tar -vf "$papelera" --delete "$archivoParaRecuperar" 1> /dev/null
        else
            echo "$archivosIguales" | awk 'BEGIN{FS=";"} {for(i=1; i < NF; i++) print $i}'
            echo "¿Qué archivo desea recuperar?"
            read opcion

            seleccion="${arrayArchivos[$opcion]}"

            elementoNumero=0
            indice=0
            IFS=$'\n'
            for archivo in $(realpath $(tar -tf "$papelera"))
            do
                let indice=$indice+1
                if [ "$seleccion" == "$archivo" ];
                then
                    elementoNumero=$indice
                fi
            done
            indice=0
            IFS=$'\n'
            for archivo in $(tar -tf "$papelera")
            do
                let indice=$indice+1
                if [ "$indice" == "$elementoNumero" ];
                then
                    tar -xvf "$papelera" "$archivo" 1> /dev/null
                    tar -vf "$papelera" --delete "$archivo" 1> /dev/null 
                fi
            done
        fi
    fi
    echo "Archivo recuperado"
}

vaciar(){
    papelera="${HOME}/papelera.zip"
    rm "$papelera"
    tar -cf "$papelera" --files-from /dev/null
}

eliminar(){
    archivoEliminar="$1"
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$archivoEliminar" ];
    then
        echo "Parámetro archivo en función eliminar no es válido"
        echo "Por favor consulte la ayuda"
        exit 1
    fi
    if [ ! -f "$papelera" ];
    then
        tar -cvf "$papelera" "$archivoEliminar" > /dev/null
    else
        tar -rvf "$papelera" "$archivoEliminar" > /dev/null
    fi
    rm "$archivoEliminar"
    echo "Archivo eliminado"
}

borrar(){
archivoParaBorrar="$1"
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existen archivos a borrar"
        exit 1
    fi
    if [ "$archivoParaBorrar" == "" ];
    then
        echo "Parámetro archivo a borrar sin informar"
        exit 1
    fi

    contadorArchivosIguales=0
    archivosIguales=""
    declare -a arrayArchivos

    IFS=$'\n'
    for archivo in $(realpath $(tar -tf "$papelera"))
    do
        rutaArchivo=$(dirname "$archivo")
        nombreArchivo=$(basename "$archivo")
        if [ "$nombreArchivo" == "$archivoParaBorrar" ];
        then
            let contadorArchivosIguales=contadorArchivosIguales+1
            archivosIguales="$archivosIguales$contadorArchivosIguales - $nombreArchivo $rutaArchivo;"
            arrayArchivos[$contadorArchivosIguales]="$archivo"
        fi
    done

    if [ "$contadorArchivosIguales" -eq 0 ];
    then
        echo "No existe el archivo en la papelera"
        exit 1
    else
        if [ "$contadorArchivosIguales" -eq 1 ];
        then
            tar -vf "$papelera" --delete "$archivoParaBorrar" 1> /dev/null 
        else
            echo "$archivosIguales" | awk 'BEGIN{FS=";"} {for(i=1; i < NF; i++) print $i}'
            echo "¿Qué archivo desea borar?"
            read opcion

            seleccion="${arrayArchivos[$opcion]}"

            elementoNumero=0
            indice=0
            IFS=$'\n'
            for archivo in $(realpath $(tar -tf "$papelera"))
            do
                let indice=$indice+1
                if [ "$seleccion" == "$archivo" ];
                then
                    elementoNumero=$indice
                fi
            done
            indice=0
            IFS=$'\n'
            for archivo in $(tar -tf "$papelera")
            do
                let indice=$indice+1
                if [ "$indice" == "$elementoNumero" ];
                then
                    tar -vf "$papelera" --delete "$archivo" 1> /dev/null 
                fi
            done
        fi
    fi
    echo "Archivo borrado"
}

# ******************* #
#        Inicio       #
# ******************* #

cantidadDeParametros=$#
opcionElegida=$1
archivoElegido=$2

if ([ $cantidadDeParametros -eq 0 ] || [ $cantidadDeParametros -gt 2 ]);
then
    echo "Ocurrió un error al invocar el script"
    echo "Por favor consulte la ayuda"
    exit 1
fi
case "$opcionElegida" in 
    "-h")
        ayuda
        exit 0
        ;;
    "-?")
        ayuda
        exit 0
        ;;
    "--help")
        ayuda
        exit 0
        ;;
    "--listar")
        listar
        exit 0
        ;;
    "--recuperar")
        recuperar "$archivoElegido"
        exit 0
        ;;
    "--vaciar")
        vaciar
        exit 0
        ;;
    "--eliminar")
        eliminar "$archivoElegido"
        exit 0
        ;;
    "--borrar")
        borrar "$archivoElegido"
        exit 0
        ;;
    *) 
        echo "Ocurrió un error al invocar el script"
        echo "Por favor consulte la ayuda"
        exit 1
        ;;
esac