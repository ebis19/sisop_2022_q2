<#
 .SYNOPSIS
  Permite contar la cantidad de líneas de código y de comentarios que poseen los archivos en una ruta pasada por parámetro y controlando solo los archivos con cierta extensión
 .DESCRIPTION
  Acciones que puede realizar: 
  • Informar la cantidad de Archvivos analizados
  • Informar la cantidad de lineas de codigo de los archivos junto a su porcentaje
  • Informar la cantidad de lineas de comentarios de los archivos junto a su porcentaje 
 
 .EXAMPLE
 .\ejercicio4.ps1 -ruta ./pruebas -ext js,css,php

#>



#-----------------------------------------------#
# Nombre del Script: contadorcodigo.sh          #
# APL 2                                         #
# Ejercicio 4                                   #
# Integrantes:                                  #
# Molina Lara                     DNI: 40187938 #
# Lopez Julian                    DNI: 39712927 #
# Gorbolino Tamara                DNI: 41668847 #
# Biscaia Elias                   DNI: 40078823 #
# Amelia Colque                   DNI: 34095247 #
# Nro entrega: 1                                #
#-----------------------------------------------#

#CARGA DE PARAMETROS
[cmdletbinding()]
Param(
    [Parameter(ParameterSetName = "ejecucion")]
    $ruta,
    [Parameter(ParameterSetName = "ejecucion")]
    $ext
)


#VALIDACIONES
if ($null -eq $ruta) {
    Write-Error "Debe indicar una ruta"
    exit 1
}

if ($null -eq $ext) {
    Write-Error "Debe indicar al menos una extension"
    exit 1
}

$existe = Test-Path "$ruta"
if($existe -ne $true ) {
    Write-Error "La dirección del directorio no existe"
    exit 0
}

#--------------------------------------------------------------------------
#CONSTANTES

$COMENTARIOSIMPLE = "//"
$COMENTARIO_MULTIPLE = "/*"
$FIN_COMENTARIO_MULTIPLE = "*/"

$COMENTARIO_ABIERTO = 1
$COMENTARIO_CERRADO = 0
#--------------------------------------------------------------------------
#VARIABLES GLOBALES
$tipoComentario = $COMENTARIO_CERRADO
$comentarios = 0
$codigo = 0
$comentariosTotales = 0
$codigoTotal = 0
$porcentajeCodigo = 0
$cantidadLineas = 0
$cantidadLineasTotales = 0
$cantidadFicheros = 0
#--------------------------------------------------------------------------


foreach ($filename in $(Get-ChildItem -Path ./"$ruta" | % { $_.Name })) {
    #leo archivos de carpeta
    
    foreach ($extension in $ext) {
        if ($filename.EndsWith(".$extension")) {#valido la extension del archivo
            
            $cantidadFicheros++

            $archivo = Get-Content "$ruta/$filename"   
        
            foreach ($linea in $archivo) {
                $cantidadLineas++

                $comienzoDeLinea = $linea.Substring(0, 2)

                $tamlinea = $linea.Length
                
                $fin = $tamlinea
                $inicio = $fin - 2
               
                $finDeLinea = $linea.Substring($inicio, 2)

                $inicio = $fin = 0

                if ($tipoComentario -eq $COMENTARIO_CERRADO) {
                    #COMENTARIOS CERRADOS   EJ. */ o ninguno

                    if ($comienzoDeLinea -eq $COMENTARIOSIMPLE) {
                        #suma comentario
                        $comentarios++
                    }
                    elseif ($comienzoDeLinea -eq $COMENTARIO_MULTIPLE) {
                        #suma comentario
                        $comentarios++

                        #abrir comentario
                        $tipoComentario = $COMENTARIO_ABIERTO

                        if ($finDeLinea -eq $FIN_COMENTARIO_MULTIPLE) {
                            #valido si el comentario multiple cierra en la misma linea
                            #cerrar comentario
                            $tipoComentario = $COMENTARIO_CERRADO
                        }
                    }
                    #COMENTARIO DE TIPO ...//....
                    elseif ("$linea" -eq "*$COMENTARIOSIMPLE*") {
                        #suma comentario
                        $comentarios++
                        
                        #suma codigo
                        $codigo++
                    }
                    #COMENTARIO DE TIPO ..../*....*/
                    elseif ("$linea" -eq "*$COMENTARIO_MULTIPLE*") {
                        #suma comentario
                        $comentarios++
                       
                        #suma codigo
                        $codigo++

                        #COMENTARRIO QUE NO CIERRA EN LA MISMA LINEA EJ. ...../*.......
                        if ("$linea" -ne "*$FIN_COMENTARIO_MULTIPLE*") {
                            #abrir comentario
                            $tipoComentario = $COMENTARIO_ABIERTO
                        }
                    }
                    else {
                        #suma codigo
                        $codigo++
                    }
                }
                elseif ($tipoComentario -eq $COMENTARIO_ABIERTO) {
                    #COMENTARIOS ABIERTOS   Ej. /*
    
                    #suma comentario
                    $comentarios++

                    if ($comienzoDeLinea -eq $FIN_COMENTARIO_MULTIPLE -or $finDeLinea -eq $FIN_COMENTARIO_MULTIPLE) {
                        #cerrar comentario
                        $tipoComentario = $COMENTARIO_CERRADO
                    }
                    elseif ($linea -eq "*$FIN_COMENTARIO_MULTIPLE*" ) {
                        #cerrar comentario
                        $tipoComentario = $COMENTARIO_CERRADO
                        #suma codigo
                        $codigo++
                        $codigoTotal++
                        Write-Host $linea
                    }
                }
            }
        

            [int]$porcentajeCodigo = $(($codigo * 100 / $cantidadLineas))

            $comentariosTotales += $comentarios
            $codigoTotal += $codigo
            $cantidadLineasTotales += $cantidadLineas
        }
    }
}

if($cantidadLineasTotales -eq 0)
{
    Write-Host "No se pudo analizar ningún archivo."
    exit 1
}

[int]$porcentajeCodigoTotal = $(($codigoTotal * 100 / $cantidadLineasTotales))
$porcentajeComentarioTotal = $((100 - $porcentajeCodigoTotal))

Write-Host "------------------------------------------------"
Write-Host "Cantidad de archivos analizados: " $cantidadFicheros
Write-Host "Cantidad de lineas de codigo: " $codigoTotal " con un porcentaje de: " $porcentajeCodigoTotal"%"
Write-Host "Cantidad de comentarios" $comentariosTotales " con un porcentaje de: " $porcentajeComentarioTotal"%"

exit 1
