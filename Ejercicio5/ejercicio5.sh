#!/bin/bash

# ++++++++++++++++++++++++++++++++++++++++++++++++++++
# Nombre del Script: ejercicio5.sh
# APL: 1
# Ejercicio: 5
# Integrantes:
# 	Molina Lara                   DNI: 40187938
# 	Lopez Julian                  DNI: 39712927
# 	Gorbolino Tamara	      DNI: 41668847                      
# 	Elias Biscaia 		      DNI: 40078823             
# 	Amelia Soledad Colque         DNI: 34095247
# Nro entrega: entrega
# +++++++++++++++++++++++++++++++++++++++++++++++++++++


Ayuda()
{
    echo "--------------------------Ayuda-----------------------------------"
    echo "Ejemplo: $0 --notas <path> --materias <path>"
    echo "  --notas <path>  Ruta del archivo a procesar"
    echo "  --materias <path> Ruta del archivo con los datos de las materias"
}

#Validacion de parametros
if [ $# -eq 1 ] || [ $# -ne 4 ] || [ $# -eq   ]
then
    	if [ $1 == "-h" ] || [ $1 == "--help" ] || [ $1 == "-?" ]
    	then
       		Ayuda;
       		exit 0;
	else
        	echo "Cantidad de parametros incorrectos, para obtener mas ayuda ejecutar el comando -h, --help o -? seguido de $0";
            	exit 1;
    	fi
fi


PARSED_ARGUMENTS=$(getopt -o '' --long "notas:,materias:" -- "$@")
echo $PARSED_ARGUMENTS

eval set -- "$PARSED_ARGUMENTS"
while true 
do 
    case "$1" in
    --notas ) notas=$2 ; shift; shift ;;
    --materias ) materias=$2; shift; shift ;;
    -- ) shift ; break;;
    * )  echo "Parametros no válidos" ; break ;;
    esac
done

#Validacion de permisos
if [ -r $notas ]
then
	echo	"Tiene Permisos" $notas
else
	echo	"No tiene permiso" $notas
	exit 1;
fi

if [ -r $materias ]
then
        echo    "Tiene Permisos" $materias
else
        echo    "No tiene permiso" $materias
        exit 1;
fi

#Procesamiento de archivo nota
IFS="|"

RECUPERATORIO=4
PARCIAL_1=2
PARCIAL_2=3
FINAL=5
ID_MATERIA=1

declare -A promocionan
declare -A abandonan
declare -A recursan
declare -A final
declare -a datosAlumno
PRIMER_LINEA=1

while	read	linea
do
	if [[ $PRIMER_LINEA == 0 ]]
	then
		datosAlumno=($linea)

		if [[ -z ${datosAlumno[$FINAL]} ]]
		then
			if [[ ${datosAlumno[$RECUPERATORIO]} > 6 ]] 
			then 
				if [[ ${datosAlumno[$PARCIAL_1]} > 6 ]] || [[ ${datosAlumno[$PARCIAL_2]} > 6 ]] 
					then
						(( promocionan[${datosAlumno[$ID_MATERIA]}]++ ))
					else
						(( final[${datosAlumno[$ID_MATERIA]}]++ ))
				fi
			elif [[ -z ${datosAlumno[$RECUPERATORIO]} ]] 
			then

						if [[ ${datosAlumno[$PARCIAL_1]} -ge 7 ]] && [[ ${datosAlumno[$PARCIAL_2]} -ge 7 ]]
							then
								(( promocionan[${datosAlumno[$ID_MATERIA]}]++ ))
						elif [[ -z ${datosAlumno[$PARCIAL_1]} ]] || [[ -z ${datosAlumno[$PARCIAL_2]} ]]
							then
								(( abandonan[${datosAlumno[$ID_MATERIA]}]++ ))

						elif [ ${datosAlumno[$PARCIAL_1]} -lt 4 ] || [ ${datosAlumno[$PARCIAL_2]} -lt 4 ]
							then
								(( recursan[${datosAlumno[$ID_MATERIA]}]++ )) 
						else
								(( final[${datosAlumno[$ID_MATERIA]}]++ ))
						fi

			elif  [ ${datosAlumno[$RECUPERATORIO]} -lt 4 ]
				then
					(( recursan[${datosAlumno[$ID_MATERIA]}]++ ))
				else
					(( final[${datosAlumno[$ID_MATERIA]}]++ ))
			fi
		fi
		
	fi

	PRIMER_LINEA=0

done < $notas


#Se procesa archivo materia
ID_MATERIA=0
DESCRIPCION_MATERIA=1
ID_DEPARTAMENTO=2
PRIMER_LINEA=1
declare -a departamento
declare -A materia
declare -A descripcionMateria

while read linea
do
	if [[ $PRIMER_LINEA == 0 ]]
        then
		datosMateria=($linea)
		
		if [[ ${datosMateria[$ID_DEPARTAMENTO]} ]]
		then
			departamento[${datosMateria[$ID_DEPARTAMENTO]}]=${datosMateria[$ID_DEPARTAMENTO]}
			
		fi

		materia[${datosMateria[$ID_MATERIA]}]=${datosMateria[$ID_DEPARTAMENTO]}
		descripcionMateria[${datosMateria[$ID_MATERIA]}]=${datosMateria[$DESCRIPCION_MATERIA]}		

	fi	
  
	PRIMER_LINEA=0
done < $materias

#Se escribe el archivo de salida
salida=$(echo "salida.txt")
touch "salida.txt"
echo "{" > "$salida"
echo "	“departamentos”: [" >> "$salida"

for depto in ${departamento[@]}
do
	echo "	   {" >> "$salida"
	echo "		“id”: " $depto >> "$salida"
	echo "		“notas”: [" >> "$salida" 
	for idMateria in ${!materia[@]}
	do
		if [[ $depto == ${materia[$idMateria]} ]]
		then
			echo "		{" >> "$salida"
        		echo "			“id_materia”: " $idMateria >> "$salida"
        		echo "			“descripcion”: " ${descripcionMateria[$idMateria]}  >> "$salida"
			echo "			“final”: " ${final[$idMateria]}  >> "$salida"
			echo "			“recursan”: " ${recursan[$idMateria]}  >> "$salida"
			echo "			“abandonaron”: " ${abandonan[$idMateria]}  >> "$salida"
			echo "			“promocionan”: " ${promocionan[$idMateria]}  >> "$salida"
			echo "		}," >> "$salida"
		fi
	done
	echo "	   }" >> "$salida"
done
echo "	]" >> "$salida"
echo "}" >> "$salida"
