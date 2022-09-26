# +++++++++++++++++++++++++++++++++++++++++++++ #
# Nombre del Script: ejercicio5.ps1             #
# APL 2                                         #
# Ejercicio 5                                   #
# Integrantes:                                  #
# Molina Lara                     DNI: 40187938 #
# Lopez Julian                    DNI: 39712927 #
# Gorbolino Tamara                DNI: 41668847 #
# Biscaia Elias                   DNI: 40078823 #
# Amelia Colque                   DNI: 34095247 #
# Nro entrega: 1                                #
# --------------------------------------------- #

<#
    .SYNOPSIS
    El script genera un archivo Json que muestra estadisticas de aprobacion y desercion del alumnado
    
    .DESCRIPTION
    A partir de un archivo con las notas de los alumnos y otro con materias, se genera un archivo Json que muestra por departamento y por materia 
    la cantidad de alumnos que recursan, van a final, promocionan o abandonan la materia

    Parametros de entrada
    -notas: path del archivo que muestra las notas de los alumnos
    -materias path del archivo con las materias en las que pueden estar los alumnos
    -Get-Help

    El orden de  los parametros es indistinto

    .EXAMPLE
    ./ejercicio5.ps1 -notas pathArchivoNotas.txt -materias pathArchivoMaterias.txt

    .EXAMPLE
    ./ejercicio5.ps1 -materias pathArchivoMaterias.txt -notas pathArchivoNotas.txt
#>

#carga de parametros
[cmdletbinding()]
Param(
    [Parameter(ParameterSetName="ejecucion")]
    $notas,
    [Parameter(ParameterSetName="ejecucion")]
    $materias
)

#VALIDACIONES
$existe = Test-Path "$notas"
if($existe -ne $true ) {
    Write-Error "La direccion del archivo notas no existe"
    exit 1
}

$existe = Test-Path "$materias"
if($existe -ne $true ) {
    Write-Error "La direccion del archivo materias no existe"
    exit 1
}

#procesa archivo nota
$RECUPERATORIO=4
$PARCIAL_1=2
$PARCIAL_2=3
$FINAL=5
$ID_MATERIA=1

$promocionan = @{ }
$abandonan = @{ }
$recursan = @{ }
$finalizan = @{ }
$datosAlumno = @()

$PRIMER_LINEA=1

$archivo = Get-Content $notas
foreach ($linea in $archivo) {
    
    if($PRIMER_LINEA -eq 0){
        $datosAlumno = $linea.Split('|')
        
        if( 0 -eq $datosAlumno[$FINAL] ){

            if([int16]$datosAlumno[$RECUPERATORIO] -gt 6){ # -gt = mayor que 

                if( [int16]$datosAlumno[$PARCIAL_1] -gt  6 -or [int16]$datosAlumno[$PARCIAL_2] -gt 6){
                    $promocionan[$datosAlumno[$ID_MATERIA]]++
                }
				else{
                    $finalizan[$datosAlumno[$ID_MATERIA]]++
                }
            }elseif (0 -eq $datosAlumno[$RECUPERATORIO]) {

                if ( [int16]$datosAlumno[$PARCIAL_1] -ge 7 -and [int16]$datosAlumno[$PARCIAL_2] -ge 7 ){ #ge mayo o igual
                    $promocionan[$datosAlumno[$ID_MATERIA]]++
                }   
				elseif ( 0 -eq $datosAlumno[$PARCIAL_1] -or  $datosAlumno[$PARCIAL_2] -eq 0 ){
                    $abandonan[$datosAlumno[$ID_MATERIA]]++
                }
				elseif ( [int16]$datosAlumno[$PARCIAL_1] -lt 4 -and [int16]$datosAlumno[$PARCIAL_2] -lt 4 ){ #menor que 
                    $recursan[$datosAlumno[$ID_MATERIA]]++
                } 
				else{
                    $finalizan[$datosAlumno[$ID_MATERIA]]++
                }
            }elseif ([int16]$datosAlumno[$RECUPERATORIO] -lt 4) {
                $recursan[$datosAlumno[$ID_MATERIA]]++
            }
            else{
                $finalizan[$datosAlumno[$ID_MATERIA]]++
            }
        }elseif ([int16]$datosAlumno[$FINAL] -lt 4 ) {
            $recursan[$datosAlumno[$ID_MATERIA]]++
        }

    }

    $PRIMER_LINEA=0
}


#procesa archivo materia
$ID_MATERIA2=0
$DESCRIPCION_MATERIA=1
$ID_DEPARTAMENTO=2
$PRIMER_LINEA=1

$departamento = @()
$materia = @{ }
$descripcionMateria = @{ }
$materias1 = @()
$datosMateria = @()

$archivo2 = Get-Content $materias
foreach ($linea in $archivo2) {

    if($PRIMER_LINEA -eq 0){
        $datosMateria = $linea.Split('|')

        if(! $departamento.Contains($datosMateria[$ID_DEPARTAMENTO])){
            $departamento+=$datosMateria[$ID_DEPARTAMENTO]
        }

        $materias1 += $datosMateria[$ID_MATERIA2]

 		$materia.Add( $datosMateria[$ID_MATERIA2] , $datosMateria[$ID_DEPARTAMENTO] )
 		$descripcionMateria.Add( $datosMateria[$ID_MATERIA2] , $datosMateria[$DESCRIPCION_MATERIA] )	
    }

    $PRIMER_LINEA=0
}

# #escribe archivo de salida

$existe = Test-Path "./salida.json"

if($existe -ne $true ) {
    New-Item -ItemType file "salida.json"
}
Out-File -FilePath "salida.json" -InputObject "{"
'     "departamentos": [' >> salida.json

$cantDepto = $departamento.Length

foreach ($depto in  $departamento) {

    "        {" >> salida.json
    -join('           "id": ',$depto,",") >> salida.json
    '           "notas": [' >> salida.json

    $cant = 0

    foreach ($idMateria in $materias1) {
        if ( $depto -eq $materia[$idMateria]  ){
            $cant++
        }
    }

   foreach ($idMateria in $materias1) {
    
        if ( $depto -eq $materia[$idMateria]  ){

            "               {" >> salida.json
            -join('                 "id_materia": ',$idMateria,",") >> salida.json
            -join('                 "descripcion": ','"',$descripcionMateria[$idMateria],'"',",") >> salida.json

            if ( $null -eq $finalizan[$idMateria] ){
                '                 "final": 0,' >> salida.json
            }
            else{
                -join('                 "final": ',$finalizan[$idMateria],",") >> salida.json
            }

            if ( $null -eq $recursan[$idMateria] ){
                '                 "recursan": 0,' >> salida.json
            }
            else{
                -join('                 "recursan": ',$recursan[$idMateria],",") >> salida.json
            }

            if ( $null -eq $abandonan[$idMateria] ){
                '                 "abandonan": 0,' >> salida.json
            }
            else{
                -join('                 "abandonan": ',$abandonan[$idMateria],",") >> salida.json
            }

            if ( $null -eq $promocionan[$idMateria] ){
                '                 "promocionan": 0' >> salida.json
            }
            else{
                -join('                 "promocionan": ',$promocionan[$idMateria],"") >> salida.json
            }

            if($cant -gt 1) {    #SI NO ES EL ULTIMO
                "               }," >> salida.json
            }else {                 #SI ES EL ULTIMO
                "               }" >> salida.json
            }

            $cant--
        }
   }

   "           ]" >> salida.json
   if($cantDepto -gt 1){
        "		    }," >> salida.json
   }else{
        "		    }" >> salida.json
   }

   $cantDepto--
}

"    ]" >> salida.json
"}" >> salida.json

