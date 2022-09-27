<#
 .SYNOPSIS

 .DESCRIPTION

 .EXAMPLE
 

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
    [Parameter(Mandatory=$true)]
    [String[]]
    [ValidateNotNullOrEmpty()]
    $accion,
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        HelpMessage = "Path to the file or files to process.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $directorio,
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        HelpMessage = "Path to the file or files to process.")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string]
    $publish

)

$acciones = @($accion -split ",")

#VALIDACIONES

if ($null -eq $accion) {
    Write-Error "Debe indicar una accion"
    exit 1
}

if ($null -eq $directorio) {
    Write-Error "Debe indicar un directorio"
    exit 1
}



if(!($acciones.Contains("compilar")) -and $acciones.Contains("publicar")){
    Write-Error "No se puede publicar sin compilar"
    exit 1
}


$existe = Test-Path "$directorio"
if ($existe -ne $true ) {
    Write-Error "La dirección del directorio no existe"
    exit 1
}

if ($acciones.Contains("publish")  -and $null -eq $publish) {
    Write-Error "Debe indicar un directorio de publicacion"
    exit 1
}

$directorio = Resolve-Path $directorio
#--------------------------------------------------------------------------

#FUNCIONES

Function Register-Watcher {
    param ($folder,$publish)
    $filter = "*.*" #all files
    $watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
        IncludeSubdirectories = $true
        EnableRaisingEvents   = $true
    }
    $listarString = '
    $name = $Event.SourceEventArgs.FullPath
     Write-Host "The file $name"'
    $listarString+= "`n"

    $pesoString = '
    $name = $Event.SourceEventArgs.FullPath
    $size = (Get-Item $name).Length
    Write-Host "The file $name has $size bytes"'
    $listarString+= "`n"
    $accionExecute= ''
    $compilarString =
    '$files = Get-ChildItem '+ $folder +' -Filter *
    $content=""
    foreach($file in $files){ 
        $content += Get-Content $file}
    $content | Out-File bin/compilado.o'
    $compilarString+= "`n"
    $compilarString+= "`n"

    $publicarString =
    '$filesPublicar = Get-ChildItem "bin" -Filter *
    foreach($file in  $filesPublicar){
            Copy-Item $file.FullName ' + $publish +
    '}'
    $publicarString+= "`n"

    foreach ($accion in $acciones)  {
        if ($accion -eq "compilar") {
            $CompilarBoolean  = $true
        }
        if ($accion -eq "publicar") {
            $PublicarBoolean  = $true
        }
        if($accion -eq "listar"){
            $ListarBoolean = $true
        }
        if($accion -eq "peso"){
            $pesoBoolean = $true
        }
    }

    if($CompilarBoolean){
        $accionExecute += " " + $compilarString
        $comp=[Scriptblock]::Create($compilarString)
        &$comp
    }
    if($PublicarBoolean){
        $accionExecute += " " + $publicarString
        $publ=[Scriptblock]::Create($publicarString)
        &$publ
    }
    if($ListarBoolean){
        $accionExecute += " " + $listarString
    }
    if($pesoBoolean){
        $accionExecute += $pesoString
    }
    Write-Host $accionExecute
    $accionExecute = [Scriptblock]::Create($accionExecute)
    Register-ObjectEvent $Watcher -EventName "Changed" -Action $accionExecute 
    Register-ObjectEvent $Watcher -EventName "Created" -Action $accionExecute
    Register-ObjectEvent $Watcher -EventName "Deleted" -Action $accionExecute
    Register-ObjectEvent $Watcher -EventName "Renamed" -Action $accionExecute   
}

Register-Watcher -folder $directorio -publish $publish
exit 0
