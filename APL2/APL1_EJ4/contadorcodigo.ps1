<#
 .SYNOPSIS
  Permite contar la cantidad de líneas de código y de comentarios que poseen los archivos en una ruta pasada por parámetro y controlando solo los archivos con cierta extensión
 .DESCRIPTION
  Acciones que puede realizar: 
  • Informar la cantidad de líneas de codigo por archivo 
  • Informar la cantidad de líneas de comentarios por archivo
  • Informar el porcentaje de codigo y comentario por archivo
  • Informar un total de las metricas anteriormente mencionadas
 
 .EXAMPLE
 .\contadorcodigo.ps1 -ruta ./pruebas -ext js,css,php

#>

#carga de parametros
[cmdletbinding()]
Param(
    [Parameter(ParameterSetName="ejecucion")]
    $ruta,
    [Parameter(ParameterSetName="ejecucion")]
    $ext
)

#validacion de parametros
if($help.IsPresent) {
    Write-Host "ayuda"
    exit 0
}
if($null -eq $ruta){
    Write-Error "Debe indicar una ruta"
    exit 1
}

if ($null -eq $ext) {
   Write-Error "debe indicar al menos una extension"
   exit 1
}

Write-Host "todo ok " $ruta " y " $ext[0]

