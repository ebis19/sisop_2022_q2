#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: ej3.sh                     #
# APL 1						                    #
# Ejercicio 3			        	            #
# Integrantes:                                  #
# Molina Lara			DNI: 40187938           #
# Lopez Julian			DNI: 39712927	        #
# Gorbolino Tamara      DNI: 41668847           #
# Biscaia Elias			DNI: 40078823	        #
# Amelia Colque			DNI: 34095247	        #
# Nro entrega: 2                                #
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

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    exit 1
fi

dir=false
publish_dir=false
options=""

while getopts "s:c:a:h" arg; do
  case $arg in
    h)
      usage
      ;;
    a)
        options=$OPTARG
      ;;
    c)
        dir=$OPTARG
      ;;
    s)
        publish_dir=$OPTARG
      ;;
  esac
done



#concatenar archivos 
concatenar() {
    IFS=$'\n';
    for file in $(ls -1 $dir); do
        if [ -f $dir/$file ]; then
            cat "$dir""/""$file" >> "bin/$dir.o"
        fi
        
    done
}

#mostrar archivos y su tamaño
mostrar(){
    for file in $(ls $dir); do
        echo $file
        du -h $dir/$file
    done
}

# split opciones y ejecutar funciones
split_opciones(){
publish=false
listar=false
peso=false
compilar=false
IFS=',' read -ra optiones <<< "$options"
    for i in "${optiones[@]}"; do
        if [ $i == "publish" ]; then
            publish=true
        elif [ $i == "listar" ]; then
            listar=true       
        elif [ $i == "peso" ]; then
            peso=true
        
        elif [ $i == "compilar" ]; then
            compilar=true
        else
            echo "Accion a monitoriar no valido"
            exit 1
        fi
    done

if ! [ -d $dir ]; then
    echo "You must specify a valid directory"
    exit 1
fi


if $compilar &&  ! [ -d "./bin" ] ; then
    mkdir "bin"
fi

if ! $compilar && $publish ; then
    echo "You can't publish without compiling"
    exit 1
fi

if ! [ -d $publish_dir ] && $publish ; then
    echo "You must specify a valid directory to publish"
    exit 1
fi

}

inotify_demonio(){
inotifywait -r -q -m -e  modify,delete,create,move $dir --format "%w%f,%e" | while read file; do
        IFS=',' read -ra var <<< "$file"
        file_name=${var[0]}
        event=${var[1]}
        if $listar ; then
            echo 'Archivo:'"$file_name", 'Evento:'"$event"
        fi
        if [ -f "$file_name" ] &&  $peso; then
            echo 'Peso:' $(du -h "$file_name")
        fi
        if $compilar; then
            concatenar
        fi
        if $publish; then
            if [ -f "bin/$dir.o"]; then
                cp "bin/$dir.o" "$publish_dir"
            fi
        fi
done
}

main(){
    split_opciones
     if $compilar; then
        concatenar
    fi
    if $publish; then
        cp "bin/$dir.o" "$publish_dir"
    fi
    inotify_demonio &
}
main
