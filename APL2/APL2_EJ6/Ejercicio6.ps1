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
<#
    .SYNOPSIS
        Papelera de reciclaje
    
    .DESCRIPTION
        Permite eliminar archivos, recuperarlos, listarlos, vaciarla y borrar un archivo dentro de la papelera.
        Se puede pasar solo un parametro a la vez.
    
    .PARAMETER [FILE]
        Indica ruta de archivo a eliminar.
    .PARAMETER -listar
        Lista los archivos dentro de la papelera
    .PARAMETER -recuperar
        Indica el nombre del archivo a recuperar de la papelera.
        Vuelve a su ubicacion original
    .PARAMETER -borrar
        Indica el nombre del archivo a borrar de la papelera
    .PARAMETER -vaciar
        Indica el nombre del archivo a vaciar de la papelera
    .EXAMPLE
        ./Ejercicio6.ps1 -listar
    .EXAMPLE
        ./Ejercicio6.ps1 -recuperar archivo
    .EXAMPLE
        ./Ejercicio6.ps1 -vaciar 
    .EXAMPLO
         ./Ejercicio6.Ps1 -eliminar archivo
    .EXAMPLO
         ./Ejercicio6.ps1 -borrar archivo
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true,Position=0,ParameterSetName="param0")]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf })]
    [string]
    $archivoAEliminar,

    [Parameter(Mandatory=$false,ParameterSetName="param1")]
    [Switch]
    $listar,
    
    [Parameter(Mandatory=$false,ParameterSetName="param2")]
    [String]
    $recuperar=$null,
    
    [Parameter(Mandatory=$false,ParameterSetName="param3")]
    [Switch]
    $vaciar,

    [Parameter(Mandatory=$false,ParameterSetName="param4")]
    [Switch]
    $borrar
)
$global:nombreScript = $MyInvocation.MyCommand.Name

$papelera = [Papelera]::New();

if($archivoAEliminar -ne "")
{
    try {
        $archivoABorrar = Get-ChildItem -Path $archivoAEliminar

        $papelera.eliminar($archivoABorrar)
    }
    catch {
        Write-Host "Error! No puede eliminar el script de papelera!"
        exit 1
    }

    Write-Host $archivoABorrar.Name "eliminado con exito!"
}
if($listar -eq $true)
{
    $papelera.listarArchivos();
}
if($restaurar -ne "")
{
    $archivoRecuperado = $papelera.recuperar($restaurar);

    Write-Host $archivoRecuperado.Name "recuperado con exito en" $archivoRecuperado.Directory
}
if($vaciar -eq $true)
{
    $papelera.vaciar();
    Write-Host "Papelera vaciada"
}
if($borrar -ne "")
{
    $archivoBorrado = $papelera.borrar($restaurar);

    Write-Host $archivoBorrado.Name "borrado con exito"
}

exit 0;

class Papelera {
    static [String]$ruta = ($HOME)+"/Papelera.zip";
    static [String[]]$headers = "nombreArchivo","rutaOriginal","nombreOriginal";
    static [String]$nombrePapelera = "papelera.papalera";
    
    Papelera ()
    {
        if( ! (Test-Path ([Papelera]::ruta) -PathType leaf))
        {
            $baseDatos = New-Item -Name ([Papelera]::nombrePapelera) -ItemType "file" -Force

            Out-File -FilePath $baseDatos.FullName

            Compress-Archive -Path $baseDatos.FullName -DestinationPath ([Papelera]::ruta)
            Remove-Item -Path $baseDatos.FullName
        }
    }

    [void] eliminar([System.IO.FileInfo] $archivo)
    {
        if($archivo.FullName -eq ($PSScriptRoot+"/"+$global:nombreScript))
        {
            throw "Imposible eliminar"
        }

        $baseDatos = $this.obtenerBaseDatos()

        $random = (Get-Random);
        $rutaOriginal = $archivo.Directory;
        $nombreOriginal = $archivo.Name;

        $random.toString() + "," + $rutaOriginal + "," + $nombreOriginal | Add-Content -Path $baseDatos.FullName

        $archivo = $this.generarNombre($random,$archivo)

        Compress-Archive -Path $archivo.FullName, $baseDatos.FullName -DestinationPath ([Papelera]::ruta) -Update
        
        $this.borrarTemporal();
        Remove-Item -Path $archivo.FullName
    }

    [System.IO.FileInfo] obtenerBaseDatos()
    {
        Expand-Archive -Path ([Papelera]::ruta) -PassThru

        $rutaArchivo = "./Papelera/"+([Papelera]::nombrePapelera)

        return (Get-ChildItem -Path $rutaArchivo);
    }

    [System.IO.FileInfo] generarNombre([Int32]$random,[System.IO.FileInfo]$archivo)
    {
        $archivo = (Rename-Item -Path $archivo.FullName -NewName $random -PassThru)

        return $archivo
    }

    [void] listarArchivos()
    {
        $baseDatos = $this.obtenerBaseDatos();
        
        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName;
        try {
            $cantidad = ($datosCsv | Measure-Object).Count

            if($cantidad -eq 0)
            {
                throw "Papelera vacia";
            }
            Write-Host "--" `t`t`t "--"
            Write-Host "Nombre" `t`t`t "Ruta"
            Write-Host "--" `t`t`t "--"
    
            $datosCsv | ForEach-Object {
                Write-Host $.nombreOriginal `t`t $.rutaOriginal
            }
        }
        catch {
            Write-Host "Papelera vacia"
        }
        finally
        {
            $this.borrarTemporal()
        }

    }

    [void] vaciar()
    {
        Remove-Item -Path ([Papelera]::ruta)
        $this = [Papelera]::New();
    }

    [void] borrarTemporal()
    {
        Remove-Item -Path "Papelera/" -Recurse 
    }
    
    [System.IO.FileInfo] recuperar([String] $archivo)
    {
        $baseDatos = $this.obtenerBaseDatos();

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreOriginal -Like $archivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if($cantidad -eq 0)
        {
            Write-Host "Archivo no encontrado en papelera"
            $this.borrarTemporal();
            exit 1;
        }

        if($cantidad -gt 1 )
        {
            $i = 1;
            foreach ($registro in $datosCsv) {
                Write-Host $i "-" $registro.nombreOriginal `t $registro.rutaOriginal
                $i++
            }
            $opcion = Read-Host "Seleccione una opcion"
            $archivoARecuperar = $datosCsv[$opcion-1]
        }
        else {
            $archivoARecuperar = $datosCsv
        }

        $rutaOriginal = ($archivoARecuperar.rutaOriginal + "/" + $archivoARecuperar.nombreOriginal)

        if((Test-Path $rutaOriginal) -eq $true)
        {
            $opcion = Read-Host "Atencion! `n
            El archivo que quiere restablecer ya existe en el directorio original `n
            ¿ Desea sobreescribirlo ? Escriba S o N: "
            if($opcion -eq "N")
            {
                $this.borrarTemporal();
                exit 0;
            }
        }

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreArchivo -ne $archivoARecuperar.nombreArchivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if($cantidad -gt 0)
        {
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
    
    [System.IO.FileInfo] borrar([String] $archivo)
    {
        $baseDatos = $this.obtenerBaseDatos();

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreOriginal -Like $archivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if($cantidad -eq 0)
        {
            Write-Host "Archivo no encontrado en papelera"
            $this.borrarTemporal();
            exit 1;
        }

        if($cantidad -gt 1 )
        {
            $i = 1;
            foreach ($registro in $datosCsv) {
                Write-Host $i "-" $registro.nombreOriginal `t $registro.rutaOriginal
                $i++
            }
            $opcion = Read-Host "Seleccione una opcion"
            $archivoABorrar = $datosCsv[$opcion-1]
        }
        else {
            $archivoABorrar = $datosCsv
        }

        $datosCsv = Import-Csv -Header ([Papelera]::headers) -Path $baseDatos.FullName | Where-Object nombreArchivo -ne $archivoABorrar.nombreArchivo

        $cantidad = ($datosCsv | Measure-Object).Count

        if($cantidad -gt 0)
        {
            $datosCsv | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content -Path $baseDatos.FullName
        }
        else {
            Out-File -FilePath $baseDatos.FullName
        }

        $rutaArchivo = "Papelera/" + ($archivoABorrar.nombreArchivo);

        $archivoBorrado = Move-Item -Path $rutaArchivo -Destination ($archivoABorrar.rutaOriginal + "/" + $archivoABorrar.nombreOriginal) -Force

        Compress-Archive -Path "Papelera/*" -DestinationPath ([Papelera]::ruta) -Force

        $this.borrarTemporal();
        Remove-Item -Path $archivoBorrado.FullName

        return $archivoBorrado;
    }
}