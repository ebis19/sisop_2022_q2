<#
 .SYNOPSIS
 Ejercicio 1 de la APL2

 .DESCRIPTION
 #--------------------------------------------------------------------------
Pregunta 1

El objetivo del scrip es listar los procesos que consumen más de 100MB de memoria RAM.
donde debe  recibir como parámetro el path de un archivo de texto donde se guardarán los procesos.
Además, debe recibir un parámetro opcional que indique la cantidad de procesos a mostrar.

Pregunta 2

Se podria validar que el numbero ingresado sea un numero entero
Y se tambien se podria validar que el path ingresado sea un path valido en los parametros de entrada
Pregunta 3
Si no se inicializa la variable $cantidad, se mostraran los 3 primeros procesos que consumen mas de 100MB de memoria RAM
pero si no se indica el path de un archivo de texto donde se guardarán los procesos
se mostrara un mensaje de error indicando que el path no existe
 .EXAMPLE
    Ejercicio1.ps1 -path C:\Users\Usuario\Desktop\procesos.txt -cantidad 5
#>
Param (
[Parameter(Position = 1, Mandatory = $false)]
[String] $pathSalida = ".\procesos.txt ",
[int] $cantidad = 3
)
$existe = Test-Path $pathSalida
if ($existe -eq $true) {
$procesos = Get-Process | Where-Object { $_.WorkingSet -gt 100MB }
$procesos | Format-List -Property Id,Name >> $pathSalida
for ($i = 0; $i -lt $cantidad ; $i++) {
Write-Host $procesos[$i].Id - $procesos[$i].Name
}
} else {
Write-Host "El path no existe"
}

# #--------------------------------------------------------------------------
# Pregunta 1
#
# El objetivo del script es listar los procesos que consumen más de 100MB de memoria RAM.
# donde debe  recibir como parámetro el path de un archivo de texto donde se guardarán los procesos.
# Además, debe recibir un parámetro opcional que indique la cantidad de procesos a mostrar.
#
# Pregunta 2
#
# Se podria validar que el numbero ingresado sea un numero entero
# Y se tambien se podria validar que el path ingresado sea un path valido en los parametros de entrada
# Pregunta 3
# Si no se inicializa la variable $cantidad, se mostraran los 3 primeros procesos que consumen mas de 100MB de memoria RAM
# pero si no se indica el path de un archivo de texto donde se guardarán los procesos
# se mostrara un mensaje de error indicando que el path no existe