#!/bin/bash
 IFS="|"
 notas=$1
 materias=$2

 RECUPERATORIO=4
 PARCIAL_1=2
 PARCIAL_2=3
 FINAL=5
 
  if [ -r $notas ]
  then
          echo    "Tiene Permisos"
  else
          echo    "No tiene permiso"
          exit 1;
  fi
 
  if [ -r $materias ]
  then
          echo    "Tiene Permisos"
  else
          echo    "No tiene permiso"
          exit 1;
  fi
 
  declare -A promocionan
  declare -A abandonan
  declare -A recursan
  declare -A final
  declare -a datosAlumno
  PRIMER_LINEA=1
 
  while   read    linea
  do
          if [[ $PRIMER_LINEA == 0 ]]
 then
                  datosAlumno=($linea)
                  echo ${datosAlumno[0]}
 
                  if [[ -z ${datosAlumno[$FINAL]} ]]
                  then
                          if [[ ${datosAlumno[$RECUPERATORIO]} > 6 ]] #Para rendir el recuperatorio -> p1 o p2 tine nota >= 4
                          then #posibilidad de promocionar o llegar a final
                                  if [[ ${datosAlumno[$PARCIAL_1]} > 6 ]] || [[ ${datosAlumno[$PARCIAL_2]} > 6 ]] #minimo un parcial con nota de promoción
                                          then
                                                  echo "promocion"
                                          else
                                                  echo "final"
                                  fi
                          elif [[ -z ${datosAlumno[$RECUPERATORIO]} ]] #si es null $$
                          then
 
                                                  if [[ ${datosAlumno[$PARCIAL_1]} -ge 7 ]] && [[ ${datosAlumno[$PARCIAL_2]} -ge 7 ]]
                                                          then
                                                                  echo "promocion"
                                                  elif [[ -z ${datosAlumno[$PARCIAL_1]} ]] || [[ -z ${datosAlumno[$PARCIAL_2]} ]]
                                                          then
                                                                  echo "abandono"
 
                                                  elif [ ${datosAlumno[$PARCIAL_1]} -lt 4 ] || [ ${datosAlumno[$PARCIAL_2]} -lt 4 ]
                                                          then
                                                                  echo "recursos"
                                                  else
                                                                  echo "final"
                                                  fi
 
                          elif  [ ${datosAlumno[$RECUPERATORIO]} -lt 4 ]
                                  then 
                                        echo "recurso"
                            else
                                        echo "final"
                            fi
                fi

        fi
                #falta contemplar finales

        PRIMER_LINEA=0

done < $notas


#Recorro nano ejercicio5.segundo archivo
ID_MATERIA=0
DESCRIPCION_MATERIA=1
ID_DEPARTAMENTO=2
PRIMER_LINEA=1
declare -A departamento
declare -A materia

while read linea
do
        if [[ $PRIMER_LINEA == 0 ]]
        then
                datosMateria=($linea)
                echo $linea
                if [[ ${datosMateria[$ID_DEPARTAMENTO]} ]]
                then
                        departamento[${datosMateria[$ID_DEPARTAMENTO]}]=${datosMateria[$DESCRIPCION_MATERIA]}
                fi

                echo "id materia " ${datosMateria[$ID_MATERIA]} "  ---- depto:  " ${datosMateria[$ID_DEPARTAMENTO]}

                materia[${datosMateria[$ID_MATERIA]}]=${datosMateria[$ID_DEPARTAMENTO]}

        fi

        PRIMER_LINEA=0
done < $materias