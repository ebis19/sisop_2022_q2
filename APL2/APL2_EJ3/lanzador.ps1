#CARGA DE PARAMETROS
[cmdletbinding()]
Param(
  [Parameter(ParameterSetName = "ejecucion")]
  $codigo,
  [Parameter(ParameterSetName = "ejecucion")]
  $acciones,
  [Parameter(ParameterSetName = "ejecucion")]
  $salida
)   

$path = Resolve-Path $codigo


Start-job -FilePath .\ejercicio3.ps1 -Name ejercicio3 -ArgumentList "$codigo", "$acciones"

exit
#Start-job -FilePath .\ejercicio3.ps1 -codigo "$path" -acciones $acciones -salida $salida