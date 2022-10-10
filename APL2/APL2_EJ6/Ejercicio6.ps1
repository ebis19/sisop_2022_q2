<#
    .SYNOPSIS
        Script que emula el comportamiento del comando rm, pero utilizando el concepto de “papelera de reciclaje”, es decir que, al borrar un archivo se tenga la posibilidad de recuperarlo en el futuro.
    
    .DESCRIPTION
        Permite eliminar archivos, recuperarlos, listarlos, vaciarla y borrar un archivo dentro de la papelera.
        Se puede pasar solo un parametro a la vez.
        El script tendrá las siguientes opciones (solo se puede utilizar una de las opciones en cada ejecución):
        -listar: lista los archivos que contiene la papelera de reciclaje, informando nombre de archivo y su ubicación original.
        -recuperar archivo: recupera el archivo pasado por parámetro a su ubicación original.
        -vaciar: vacía la papelera de reciclaje (eliminar definitivamente).
        -eliminar archivo: elimina el archivo (o sea, que lo envíe a la papelera de reciclaje).
        -borrar archivo: borra un archivo de la papelera, haciendo que no se pueda recuperar.
    .PARAMETER [FILE]
        Indica ruta de archivo a eliminar.
    .PARAMETER -listar
        Lista los archivos dentro de la papelera
    .PARAMETER -recuperar
        Indica el nombre del archivo a recuperar de la papelera.
        Vuelve a su ubicacion original
    .PARAMETER -vaciar
        Indica el nombre del archivo a vaciar de la papelera
    .PARAMETER -eliminar
        Indica el nombre del archivo a borrar de la papelera
    .PARAMETER -borrar
        Indica el nombre del archivo a borrar de la papelera

    .EXAMPLE
        ./Ejercicio6.ps1 -listar
    .EXAMPLE
        ./Ejercicio6.ps1 -recuperar archivo
    .EXAMPLE
        ./Ejercicio6.ps1 -vaciar 
    .EXAMPLE
         ./Ejercicio6.Ps1 -eliminar archivo
    .EXAMPLE
         ./Ejercicio6.ps1 -borrar archivo
#>

#-----------------------------------------------#
# Nombre del Script: Ejercicio6.ps1             #
# APL 2                                         #
# Ejercicio 6                                   #
# Integrantes:                                  #
# Molina Lara                     DNI: 40187938 #
# Lopez Julian                    DNI: 39712927 #
# Gorbolino Tamara                DNI: 41668847 #
# Biscaia Elias                   DNI: 40078823 #
# Amelia Colque                   DNI: 34095247 #
# Nro entrega: 1                                #
#-----------------------------------------------#

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $true, Position = 0, ParameterSetName = "param0")]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string]
    $eliminar,

    [Parameter(Mandatory = $false, ParameterSetName = "param1")]
    [Switch]
    $listar,
    
    [Parameter(Mandatory = $false, ParameterSetName = "param2")]
    [String]
    $recuperar,
    
    [Parameter(Mandatory = $false, ParameterSetName = "param3")]
    [Switch]
    $vaciar,

    [Parameter(Mandatory = $false, ParameterSetName = "param4")]
    [string]
    $borrar
)
$global:nombreScript = $MyInvocation.MyCommand.Name

$papelera = [Papelera]::New();

if ($eliminar -ne "") {
    try {
        $archivoABorrar = Get-ChildItem -Path $eliminar

        $papelera.eliminar($archivoABorrar)
    }
    catch {
        Write-Host "Error! No puede eliminar el script de papelera!"
        exit 1
    }

    #Write-Host $archivoABorrar.Name "eliminado con exito!"
    Write-Host "Archivo eliminado con exito!"
}
elseif ($listar -eq $true) {
    $papelera.listarArchivos();
}
elseif ($recuperar -ne "") {
    $archivoRecuperado = $papelera.recuperar($recuperar);

    #Write-Host $archivoRecuperado.Name "recuperado con exito en" $archivoRecuperado.Directory
    Write-Host "Archivo recuperado con exito"
}
elseif ($vaciar -eq $true) {
    $papelera.vaciar();
    Write-Host "Papelera vaciada"
}
elseif ($borrar -ne "") {
    $archivoBorrado = $papelera.borrar($borrar);

    #Write-Host $archivoBorrado.Name "borrado con exito"
    Write-Host "Archivo borrado con exito"
}

exit 0;

class Papelera {
    static [String]$ruta = ($HOME) + "/Papelera.zip";
    static [String[]]$headers = "nombreArchivo", "rutaOriginal", "nombreOriginal";
    static [String]$nombrePapelera = "papelera.papalera";
    
    Papelera () {
        if ( ! (Test-Path ([Papelera]::ruta) -PathType leaf)) {
            $baseDatos = New-Item -Name ([Papelera]::nombrePapelera) -ItemType "file" -Force

            Out-File -FilePath $baseDatos.FullName

            Compress-Archive -Path $baseDatos.FullName -DestinationPath ([Papelera]::ruta)
            Remove-Item -Path $baseDatos.FullName
        }
    }

    [void] eliminar([System.IO.FileInfo] $archivo) {
        if ($archivo.FullName -eq ($PSScriptRoot + "/" + $global:nombreScript)) {
            throw "Imposible eliminar"
        }

        $baseDatos = $this.obtenerBaseDatos()

        $random = (Get-Random);
        $rutaOriginal = $archivo.Directory;
        $nombreOriginal = $archivo.Name;

        $random.toString() + "," + $rutaOriginal + "," + $nombreOriginal | Add-Content -Path $baseDatos.FullName

        $archivo = $this.generarNombre($random, $archivo)

        Compress-Archive -Path $archivo.FullName, $baseDatos.FullName -DestinationPath ([Papelera]::ruta) -Update
        
        $this.borrarTemporal();
        Remove-Item -Path $archivo.FullName
    }

    [System.IO.FileInfo] obtenerBaseDatos() {
        Expand-Archive -Path ([Papelera]::ruta) -PassThru

        $rutaArchivo = "./Papelera/" + ([Papelera]::nombrePapelera)

        return (Get-ChildItem -Path $rutaArchivo);
    }

    [System.IO.FileInfo] generarNombre([Int32]$random, [System.IO.FileInfo]$archivo) {
        $archivo = (Rename-Item -Path $archivo.FullName -NewName $random -PassThru)

        return $archivo
    }

    [void] listarArchivos() {
        $baseDatos = $this.obtenerBaseDatos();
        
        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName;
        try {
            $cantidad = ($datosCsv | Measure-Object).Count
            if ($cantidad -eq 0) {
                throw "Papelera vacia";
            }
            #Write-Host "--" `t`t`t "--"
            Write-Host "Nombre" `t`t`t "Ruta"
            Write-Host "------" `t`t`t "----"
    
            $datosCsv | ForEach-Object {
                Write-Host $_.nombreOriginal `t`t $_.rutaOriginal
            }
        }
        catch {
            Write-Host "Papelera vacia"
        }
        finally {
            $this.borrarTemporal()
        }
    }

    [void] vaciar() {
        Remove-Item -Path ([Papelera]::ruta)
        $this = [Papelera]::New();
    }

    [void] borrarTemporal() {
        Remove-Item -Path "Papelera/" -Recurse 
    }
    
    [System.IO.FileInfo] recuperar([String] $archivo) {
        $baseDatos = $this.obtenerBaseDatos();

        # valido si la papelera esta vacia
        $datosCsv2 = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName;
        $cantidad2 = ($datosCsv2 | Measure-Object).Count
        if ($cantidad2 -eq 0) {
            Write-Host "Papelera vacia";
            exit 1;
        }

        # valido si existe en papelera el archivo a recuperar
        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreOriginal -Like $archivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if ($cantidad -eq 0) {
            Write-Host "Archivo no encontrado en papelera"
            $this.borrarTemporal();
            exit 1;
        }

        if ($cantidad -gt 1 ) {
            $i = 1;
            foreach ($registro in $datosCsv) {
                Write-Host $i "-" $registro.nombreOriginal `t $registro.rutaOriginal
                $i++
            }
            $opcion = Read-Host "Seleccione una opcion"
            $archivoARecuperar = $datosCsv[$opcion - 1]
        }
        else {
            $archivoARecuperar = $datosCsv
        }

        $rutaOriginal = ($archivoARecuperar.rutaOriginal + "/" + $archivoARecuperar.nombreOriginal)

        if ((Test-Path $rutaOriginal) -eq $true) {
            $opcion = Read-Host "Atencion! `n
            El archivo que quiere restablecer ya existe en el directorio original `n
            ¿ Desea sobreescribirlo ? Escriba S o N: "
            if ($opcion -eq "N") {
                $this.borrarTemporal();
                exit 0;
            }
        }

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreArchivo -ne $archivoARecuperar.nombreArchivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if ($cantidad -gt 0) {
            $datosCsv | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content -Path $baseDatos.FullName
        }
        else {
            Out-File -FilePath $baseDatos.FullName
        }

        $rutaArchivo = "Papelera/" + ($archivoARecuperar.nombreArchivo);
        #$archivoRecuperado = Move-Item -Path $rutaArchivo -Destination ($archivoARecuperar.rutaOriginal + "/" + $archivoARecuperar.nombreOriginal) -Force -PassThru;

        $archivoRecuperado = Move-Item -Path $rutaArchivo -Destination ($archivoARecuperar.rutaOriginal + "/" + $archivoARecuperar.nombreOriginal) -Force
        
        Compress-Archive -Path "Papelera/*" -DestinationPath ([Papelera]::ruta) -Force

        $this.borrarTemporal();

        return $archivoRecuperado;
    }
    
    [System.IO.FileInfo] borrar([String] $archivo) {
        $baseDatos = $this.obtenerBaseDatos();

        # valido si la papelera esta vacia
        $datosCsv2 = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName;
        $cantidad2 = ($datosCsv2 | Measure-Object).Count
        if ($cantidad2 -eq 0) {
            Write-Host "Papelera vacia";
            exit 1;
        }

        # valido que el archivo a borrar existe en papelera
        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreOriginal -Like $archivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if ($cantidad -eq 0) {
            Write-Host "Archivo no encontrado en papelera"
            $this.borrarTemporal();
            exit 1;
        }

        if ($cantidad -gt 1 ) {
            $i = 1;
            foreach ($registro in $datosCsv) {
                Write-Host $i "-" $registro.nombreOriginal `t $registro.rutaOriginal
                $i++
            }
            $opcion = Read-Host "Seleccione una opcion"
            $archivoABorrar = $datosCsv[$opcion - 1]
        }
        else {
            $archivoABorrar = $datosCsv
        }

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreArchivo -ne $archivoABorrar.nombreArchivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if ($cantidad -gt 0) {
            $datosCsv | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content -Path $baseDatos.FullName
        }
        else {
            Out-File -FilePath $baseDatos.FullName
        }

        $rutaArchivo = "Papelera/" + ($archivoABorrar.nombreArchivo);

        #$archivoBorrado = Move-Item -Path $rutaArchivo -Destination ($archivoABorrar.rutaOriginal + "/" + $archivoABorrar.nombreOriginal) -Force

        Compress-Archive -Path "Papelera/*" -DestinationPath ([Papelera]::ruta) -Force
        
        $this.borrarTemporal();
        #Remove-Item -Path $archivoBorrado.FullName

        #return $archivoBorrado;
        return $rutaArchivo;
    }
}