#!/bin/bash

#-----------------------------------------------#
# Nombre del Script: ejercicio2.sh              #
# APL 1                                         #
# Ejercicio 2                                   #
# Integrantes:                                  #
# Molina Lara                     DNI: 40187938 #
# Lopez Julian                    DNI: 39712927 #
# Gorbolino Tamara                DNI: 41668847 #
# Biscaia Elias                   DNI: 40078823 #
# Amelia Colque                   DNI: 34095247 #
# Nro entrega: 3                                #
#-----------------------------------------------#
IFS='
' 

function ayuda() {
    echo "**********************************************************"
    echo " Este script procesa archivos de log, donde se registraron"
    echo " todas las llamadas realizadas en una semana por un call  "
    echo " center. Se detalla el inicio y el fin de las mismas y el "
    echo " usuario.                                                 "
    echo " Obtiene y muestra por pantalla lo siguiente:             " 
    echo "  1-Promedio de tiempo de las llamadas realizadas por dia." 
    echo "  2-Promedio de tiempo y cantidad por usuario por dia.    " 
    echo "  3-Los 3 usuarios con mas llamadas en la semana.         " 
    echo "  4-Cantidad de llamadas que no superan la media de tiempo" 
    echo "    por dia.                                              " 
    echo "  5-El usuario que tiene mas cantidad de llamadas por     " 
    echo "    debajo de la media en la semana.                      "     
    echo "                                                          "    
    echo " Ejemplo:                                                 "
    echo "  1) Consultar la ayuda:                                  "
    echo "     ./ejercicio2.sh -h                                   "
    echo "     ./ejercicio2.sh -?                                   "
    echo "     ./ejercicio2.sh --help                               "   
    echo "                                                          " 
    echo "  2) Ejecutar el script:                                  "
    echo "     ./ejercicio2.sh --logs /home/desktop/carpeta         "  
    echo "                                                          " 
    echo "**********************************************************"
}

# Validacion en la cantidad de parametros
if [[ $# -eq 0 || $# -gt 2 || ($# -eq 1 && $1 != "-h" && $1 != "-?" && $1 != "--help") ]]; 
then
    echo "Error en la cantidad de parametros introducidos."
    echo "Ingresar -h -? o --help para consultar ayuda."
    exit 1
fi

# guardo la ruta donde esta el script
ruta=${PWD}
#para que acepte los parametros largos y cortos
options=$(getopt -o "l:h,?" -l "logs:,help" -a -- "$@")
eval set -- "$options"

# Validación de parámetros
while true
do
    case "$1" in
        -l|--logs) # Directorio entrada
            dir_entrada=$2
            if [ ! -d "$dir_entrada" ];
            then
                dir_entrada="${ruta}/$2"
                
                if  [ ! -d "$dir_entrada" ];
                then
                    echo "No es un directorio valido"
                    exit 1
                fi                   
            fi

            if [ ! -r "$dir_entrada" ];
            then
                echo "No posee permisos de lectura sobre el directorio"
                exit 1
            fi
            if [ ! -w "$dir_entrada" ]
            then
                echo "No posee permisos de escritura sobre el directorio"
                exit 1
            fi
            break
            ;;
        -h|-?|--help)
            ayuda
            exit 0
            ;;
        *)
            echo "Parámetros incorrectos. Use -h, -?, --help para obtener ayuda."
            exit 0
            ;;
    esac
done



echo `mkdir temp`
echo `mkdir temp2`
echo `mkdir temp3`
# leo los archivos que estan dentro del directorio
for file in $(ls $dir_entrada) 
do  
    rutaFile=$dir_entrada/$file
    archTemp=temp/"$file"_temp1.txt        #archivo para guardar los registros ordenados por usuario
    archTemp0=temp/"$file"_valido_temp1.txt  #archivo donde guardar registros validos
    archTemp1=temp/"$file"_pares_temp1.txt #archivo para guardar los pares de usuarios
    archTemp2=temp2/"$file"_temp2.txt
    # ordeno el archivo por usuario
    echo `sort -k 4 -t - $rutaFile -o $archTemp`

    cat $archTemp | awk '
    /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]-[A-Za-z]/{       
        split($1,fecha,"-")
        split($2,hora,":")
        split(hora[3],seg,"-")
        if (fecha[2] >= "01" && fecha[2] <= "12")   #valido mes
            if (fecha[3] >= "01" && fecha[3] <= "31")   #valido dia
                if (hora[1] >= "00" && hora[1] <= "23") #valido hora
                    if (hora[2] >= "00" && hora[2] <= "59") #valido minuto
                        if (seg[1] >= "00" && seg[1] <= "59") #valido segundo
                            print $0
    }'> $archTemp0

    # VALIDAMOS QUE TODOS TENGAN SU PAR
    cat $archTemp0 | awk ' 
    BEGIN { FS = "-"
    regAnt = "vacio"
    userAnt = "vacio"
    }
    {
        regAct = $0
        userAct = $4
        if (userAct == userAnt){
            print regAnt
            print regAct
            getline
            regAnt = $0
            userAnt = $4
        } else {
            regAnt = regAct
            userAnt = userAct
        }  
    }'> $archTemp1
    # unifico en una linea los pares de llamadas y calculo el tiempo de cada llamada
    # calculo el promedio de tiempo de las llamadas realizadas
    cat $archTemp1 | awk ' 
    BEGIN { ARGC = 2 
    FS = "-"
    }
	{ 
        lineaA = $0
        split($3,dh," ")
        split(dh[2],hora,":")
        inicio = $1 " " $2 " " dh[1] " " hora[1] " " hora[2] " " hora[3]
        lineaA = inicio " " $4
	    getline
        lineaB = $0
        split($3,dh," ")
        split(dh[2],hora,":")
        fin = $1 " " $2 " " dh[1] " " hora[1] " " hora[2] " " hora[3]
        lineaB = fin " " $4
        
        t1 = mktime(inicio) # YYYY MM DD HH MM SS
        t2 = mktime(fin)
        dif = t2 - t1   # diferencia de segundos
        suma += dif

        # AAAA1 MM1 DD1 HH1 DD1 SS1 user1 AAAA2 MM2 DD2 HH2 DD2 SS2 user2 dif
        lineaAB = lineaA " " lineaB " " dif
        print lineaAB
	}
    END{
        promedio = suma / (NR/2)
        print "promedio: " promedio
    }
    '> $archTemp2

    # Cuántas llamadas no superan la media de tiempo por día
    cat $archTemp2 | awk ' 
    {   
        if (NR == 1)
            fecha = $1 "-" $2 "-" $3

        tiempo[NR] = $NF

        # Si no es la primera vez que tratamos esta clave...
		if (count[$14] != "") {
			count[$14]++
			col_sum[$14] += $15
		} else {
			count[$14] = 1
			col_sum[$14] = $15
		}
    }
    END{
        print "Fecha: " fecha
        promedio = tiempo[NR]
        contar = 0
        for (k in tiempo) {
            if (k != NR && tiempo[k] < promedio)
                contar++
		}
        print "Promedio de tiempo y cantidad por usuario por día: "
        for (k in count) {
            if (k != "") {
                promUsuXdia = col_sum[k] / count[k]
                print "     usuario: " k " - promedio tiempo: " promUsuXdia " - cantidad: " count[k]  
            }
			    
		}

        print "Promedio de tiempo de las llamadas realizadas por día: " promedio
        print "cantidad llamadas que no superan la media de tiempo por día: " 
        print "     media de tiempo por dia: " promedio " - cantidad: " contar
    }'
done

archTemp3=temp3/semanal_temp3.txt
rutaTemp2=${ruta}/temp2

for file in $(ls $rutaTemp2) 
do  
    rutaFile=$rutaTemp2/$file
    # unifico los dias en un solo archivo para los calculos semanales
    cat $rutaFile | awk ' 
    {   
        if ($1 != "promedio:")
            print $0
    }
    '>> $archTemp3
done

archTemp4=temp3/totSemXUsu_temp3.txt
cat $archTemp3 | awk ' 
    {   
        # Si no es la primera vez que tratamos esta clave...
		if (count[$14] != "") {
			count[$14]++
			col_sum[$14] += $15
		} else {
			count[$14] = 1
			col_sum[$14] = $15
		}
    }
    END{
        for (k in count) {
            if (k != "") {
                promUsuXsem = col_sum[k] / count[k]
                #print "usuario: " k " - promedio tiempo: " promUsuXsem " - cantidad: " count[k]  
                print k " " promUsuXsem " " count[k]  
                
                cantSem += count[k]
                sumSem += col_sum[k]
            }
		}
        promGralSem = sumSem / cantSem 
        print "general semanal- cantSem: " cantSem "  sumSem: " sumSem "  promGralSem: " promGralSem 

    }'> $archTemp4

    archTemp5=temp3/ord_temp3.txt
    echo `sort -k 3 -n -r $archTemp4 -o $archTemp5`

    cat $archTemp5 | awk '
    BEGIN{
        print "Los 3 usuarios con más llamadas en la semana: "
    }
    {   
        if (NR < 4)
            print "     cantidad: " $3 " - usuario: " $1
    }'

    archTemp6=temp3/ultimo_temp3.txt

    # grabo el ultimo registro donde esta el promGralSem
    cat $archTemp5 | awk '
    END{
        print $0
    }'>$archTemp6

    # AGREGO en el archivo de salida todos los registros de entrada
    cat $archTemp3 | awk ' 
    {   
        print $0
    }'>> $archTemp6

cat $archTemp6 | awk ' 
    {   
        if (NR == 1)
            mediaSem = $8

        # Si no es la primera vez que tratamos esta clave...
		if (count[$14] != "") {
            if ($15 < mediaSem)
			    count[$14]++
			    col_sum[$14] += $15
		} else {
			count[$14] = 1
			col_sum[$14] = $15
		}
    }
    END{
        max=0
        for (k in count) {
            if (k != "") {
                if (count[k] > max){
                    max = count[k]
                    usuario = k
                }
                    
            }
		}
        print "El usuario que tiene más cantidad de llamadas por debajo de la media en la semana: "
        print "     usuario: " usuario " - " "cantidad llamadas: " max " - " "media semanal: " mediaSem
    }'

# elimino la carpeta temporal
echo `rm -r temp*`
exit 1


#Se pide obtener y mostrar por pantalla los siguientes datos uno debajo del otro:
#1. Promedio de tiempo de las llamadas realizadas por día.
#2. Promedio de tiempo y cantidad por usuario por día.
#3. Los 3 usuarios con más llamadas en la semana.
#4. Cuántas llamadas no superan la media de tiempo por día
#5. El usuario que tiene más cantidad de llamadas por debajo de la media en la semana.