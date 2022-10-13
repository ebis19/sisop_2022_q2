
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

<#
    .SYNOPSIS
    El script monitorea  los archvos de un directorio especificado en -c
    
    .DESCRIPTION
    
    Parametros de entrada
    -c direccion del directorio que contiene los archivos a monitoriar
    -a lista de accciones a realizar. Acciones permitas listar,compilar,publicar,peso
    -s direccion del directorio donde se guardan las publicaciones
 

    .EXAMPLE
    ./ejercicio3.ps1 -c ./dir -a listar,compilar
    ./ejercicio3.ps1 -c ./dir -a compilar,publicar -s ./publicado
#>

#CARGA DE PARAMETROS
[cmdletbinding()]
Param(
    [Parameter(ParameterSetName = "ejecucion")]
    $c,
    [Parameter(ParameterSetName = "ejecucion")]
    $a
   # [Parameter(ParameterSetName = "ejecucion")]
  #  $s
)   
 

#VALIDAR

$acciones = @($a -split ",")

#-----------------------------------------


# define a function that gets called for every change:
function invoke_action
{
  param
  (
    [Parameter(Mandatory)]
    [System.IO.WaitForChangedResult]
    $ChangeInformation,
    [Parameter(Mandatory)]
    [System.String]
    $File
  )
  
  foreach ($accion in $acciones)  {
    if ($accion -eq "compilar") {
        "compilar"
    }
    if ($accion -eq "publicar") {
       "publicar"
    }
    if($accion -eq "listar"){
        $ChangeInformation | Out-String | Write-Host -ForegroundColor DarkYellow
    }
    if($accion -eq "peso"){
      $size = (Get-Item $File).Length / 1Kb
      Write-Host "Archivo:" $File "Peso:" $size"Kb" -ForegroundColor DarkYellow

    }
  }

}

# use a try...finally construct to release the
# filesystemwatcher once the loop is aborted
# by pressing CTRL+C

function waching {

  $c = Resolve-Path $c 

  # specify the path to the folder you want to monitor:
  $Path = $c

  # specify which files you want to monitor
  $FileFilter = '*'  

  # specify whether you want to monitor subfolders as well:
  $IncludeSubfolders = $true

  # specify the file or folder properties you want to monitor:
  $AttributeFilter =  [IO.NotifyFilters]::LastWrite

  # specify the type of changes you want to monitor:
  $ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted, [System.IO.WatcherChangeTypes]::Changed,  [System.IO.WatcherChangeTypes]::Renamed

  # specify the maximum time (in milliseconds) you want to wait for changes:
  $Timeout = 1000


  try
  {
    Write-Warning "Se inicio el monitoreo de $Path"

    # create a filesystemwatcher object
    $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
      IncludeSubdirectories = $IncludeSubfolders
      NotifyFilter = $AttributeFilter
    }
   

    # start monitoring manually in a loop:
    do
    {
      # wait for changes for the specified timeout
      # IMPORTANT: while the watcher is active, PowerShell cannot be stopped
      # so it is recommended to use a timeout of 1000ms and repeat the
      # monitoring in a loop. This way, you have the chance to abort the
      # script every second.
      $result = $watcher.WaitForChanged($ChangeTypes, $Timeout)
      # if there was a timeout, continue monitoring:
      if ($result.TimedOut) { continue }
      $file = "$Path" + "/" + $result.Name

      invoke_action -Change $result -File $file
            
      # $action.SourceEventArgs | Out-String
      # $watcher | Get-Member -MemberType Property |Out-String #-MemberType Details 
      # the loop runs forever until you hit CTRL+C    
    } while ($true)
  }
  finally
  {
    # release the watcher and free its memory:
    $watcher.Dispose()
    Write-Warning 'Fin del monitoreo'
  }
}

waching