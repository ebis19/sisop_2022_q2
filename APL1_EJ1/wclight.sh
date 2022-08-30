#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: wclight.sh                 #
# APL 1						#
# Ejercicio 1				        #
# Integrantes:                                  #
# Molina Lara			DNI: 40187938	#
# Lopez Julian			DNI: 39712927	#
# Gorbolino Tamara  		DNI: 41668847	#
# Biscaia Elias			DNI: 40078823	#
# Amelia Colque			DNI: 34095247	#
# Entrega                                     	#
#-----------------------------------------------#

#Mensaje de error de sintaxis y de ayuda
ErrorS()
{
  echo "Error. La sintaxis del script es la siguiente:"
  echo "Contar la cantidad de lineas: $0 nombre_archivo L"
  echo "Contar la cantidad de caracteres: $0 nombre_archivo C"
  echo "Contar la cantidad de caracateres de la linea mas larga: $0 nombre_archivo M"
}

#Mensaje de error de permiso
ErrorP() {
  echo "Error " "$1" " no tiene permisos de lectura" # COMPLETAR
}

#valida si la cantidad de parametros es la correcta
if test $# -lt 2; then
  ErrorS
fi

#valida que el primer parametro tenga permiso de lectura, en caso de que no los tenga se envia un mensaje de error
if ! test -r "$1"; then
  ErrorP
#En caso de tener el permiso, se ejecuta el conteo correspondiente segun lo indique el segundo parametro
elif test -f "$1" && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then
  if test "$2" = "L"; then
    res=`wc -l $1`
    echo "Cantidad de lineas: $res"
  elif test "$2" = "C"; then
    res=`wc -m $1`
    echo "Cantidad de caraacteres: $res"
  elif test "$2" = "M"; then
    res=`wc -L $1`
    echo "Cantidad de caracateres de la linea mas larga: $res" # COMPLETAR
  fi
#Si el segundo parametro es invalido se envia el mensaje de error correspondiente
else
    ErrorS
fi


#1. Cual es el objetivo de este script?
#El objetivo es que a partir de un archivo se muestre la cantidad de caracteres, la cantidad de lineas o la cantidad maxima de caracteres en una linea,
#de dicho archivo.

#2. Que parametros recibe?
#Recibe dos parametros, uno debe ser un archivo y otro el tipo de lectura que se le quiere realizar.
#El tipo de lectura pueden ser tres:
#"L" para contar la cantidad de lineas.
#"C" para contar la cantidad de caracteres.
#"M" para contar la cantidad de caracateres de la linea mas larga.

#3. Comentar el codigo segun la funcionalidad (no describa los comandos, indique la logica)
#COMENTARIOS EN EL CODIGO

#4. Completar los "echo" con el mensaje correspondiente.
#COMPLETADO EN EL CODIGO

#5. Que informacion brinda la variable "$#"? Que otras variables similares conocen? Expliquelas.
#Muestra la cantidad de parametros recibidos por el script.
#Los similares que conocemos son:
#$0 Contiene el nombre del script.
#$@ Lista de todos los parámetros pasados al script
#$* Cadena con todos los parámetros pasados al script.
#$? Resultado del último comando ejecutado.
#$$ El PID de la shell actual o proceso ejecutado.
#$! El PID del último comando ejecutado en segundo plano.

#6. Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shellscripts.
#Existen las comillas dobles ("), simples (') y el acento grave `
#Comillas dobles: Se utilizan para evitar la separacion entre cadena de caracteres con espacio utilizando en una variable.
#Comillas simples: Se utilizan para convertir caracteres especiales en cadenas de texto literales.
#Acento grave: Se utilizan para que bash interprete el comando como propio y sea capaz de ejecutarlo. 
