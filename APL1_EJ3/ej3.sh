
#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: ej3.sh                     #
# APL 1					        #
# Ejercicio 3               			#
# Integrantes:                                  #
# Molina Lara			DNI: 40187938   #
# Lopez Julian			DNI: 39712927	#
# Gorbolino Tamara      	DNI: 41668847   #
# Biscaia Elias			DNI: 40078823	#
# Amelia Colque			DNI: 34095247	#
# Entrega                                    	#
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
    echo "  -a <action> Action to perform"
    echo "  -s <path>  Path to publish"
    exit 1
}

if [ $# -eq 0 ]; then
    echo "No se ha especificado un directorio"
    exit 1
fi


#!/bin/bash
while getopts "h:s:c:a:" arg; do
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
        cat "$dir""/""$file" >> "bin/$dir.o"
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
        fi
        if [ $i == "listar" ]; then
            listar=true
        fi       
        if [ $i == "peso" ]; then
            peso=true
        fi
        if [ $i == "compilar" ]; then
            compilar=true
        fi
    done
if ! $compilar && $publish ; then
    echo "No se puede publicar sin compilar"
    exit 1
fi
}

inotify_demonio(){
inotifywait -m -e modify,create,delete,move $dir --format "%f" | while read file; do
        if $listar ; then
            echo 'Archivo modificado:'"$dir/$file"
        fi
        if $peso; then
            echo 'Peso:' $(du -h "$dir/$file")
        fi
        if $compilar; then
            concatenar
        fi
        if $publish; then
             cp "bin/$dir.o" "$publish_dir"
        fi
done
}

main(){
    split_opciones
    inotify_demonio &
}

main