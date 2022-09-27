<#
    .SYNOPSIS
        Este script procesa archivos de log, donde se registraron todas las llamadas realizadas en una semana por un call center. Se detalla el inicio y el fin de las mismas y el usuario.
    .DESCRIPTION
        Obtiene y muestra por pantalla lo siguiente: 
        1-Promedio de tiempo de las llamadas realizadas por dia.
        2-Promedio de tiempo y cantidad por usuario por dia. 
        3-Los 3 usuarios con mas llamadas en la semana.
        4-Cantidad de llamadas que no superan la media de tiempo por dia.
        5-El usuario que tiene mas cantidad de llamadas por debajo de la media en la semana.
    .PARAMETER -logs
        Directorio de entrada de archivos de texto.
    .EXAMPLE
        Ejercicio2.ps1 -logs DIRECTORIO

    .NOTES
        Al final del proceso se visualizan los registros erroneos
#>

Param(
  [Parameter(Mandatory = $True)]
  [ValidateScript({ 
      if (-Not ( Test-Path -path $_)) {
        throw "El directorio no existe."
      }
      if (-Not ( Test-Path -path $_ -PathType Container)) {
        throw "El argumento Path debe ser una carpeta. Las rutas de archivos no están permitidas."
      }
      return $true
    })]
  [string]$logs
)

$directorio = $logs
$tempArch6 = New-Item "tempArch6" -itemType Directory
$tempArch7 = New-Item "tempArch7" -itemType Directory
#$pattern = ‘SRV[A-Z]{2,4}\d{2}’


#$pattern = re.compile(r'\b\d{4}[-/]\d{2}[-/]\d{2}\s\d{2}:\d{2}:\d{2}\s[-+]\d{4}\b')
Get-ChildItem $directorio -File | ForEach-Object {
  # validamos los registros leidos
  Get-Content $_ | ForEach-Object {
    $ErrorActionPreference = "SilentlyContinue"
    $fecha = $_.Split(" ")[0]
    $horaUsuario = $_.Split(" ")[1]
    $hora = $horaUsuario.Split("-")[0]
    $fechaValida = $null
    $horaValida = $null
    #Write-Host "fecha: " $fecha
    #Write-Host "horaUsuario: " $horaUsuario
    #$fecha = ($_ | Select-String -Pattern '\w+-\w+-\w+' | ForEach-Object { $_.Matches.value })
    #$horaUsuario = ($_ | Select-String -Pattern '\w+:\w+:\w+-\w+' | ForEach-Object { $_.Matches.value })
    
    $pattern = ‘\d{4}\-d{2}\-\d{2}’
    if (!($fecha -match $pattern)) {
      $fechaValida = ([datetime]::ParseExact($fecha, "yyyy-MM-dd", $null)).ToString('yyyy-MM-dd')
    }
    
    $pattern = '[0-9][0-9]'
    #$pattern = '\d\d'
    $hh = $hora.Split(":")[0]
    $mm = $hora.Split(":")[1]
    $ss = $hora.Split(":")[2]
    #Write-Host "hora: " $hora
    #Write-Host "hh: " $hh " mm: " $mm " ss: " $ss
    if ($hh -match $pattern) {
      if ($mm -match $pattern) {
        if ($ss -match $pattern) {
          $hhN = $hh
          #if ($hhN -lt "24" && $hhN -ge "0" ) {
          #  Write-Host "hora valida numerica: " $hhN.GetType()
          #}
          $horaValida = $hora
          #Write-Host "hora valida: " $horaValida
        }
      }
    }
      
    $usuario = $horaUsuario.Split("-")[1]
    
    #Write-Host "fecha valida: " $fechaValida
    if ( ($fechaValida) -ne $null ) {
      #Write-Host "Sin errores en fecha: " $fechaValida " " $_
      if ($horaValida -ne $null) {
        #Write-Host "Sin errores en hora: " $hora " " $_
        if ($usuario) {
          #Write-Host "Sin errores en usuario: " $usuario " " $_
          $_ | Out-File -FilePath $tempArch6\"temp_"$archivo"_sinErrores".txt –Append
        }
        else {
          #Write-Host "Usuario erronea: " $_
          $_ | Out-File -FilePath $tempArch7\"temp_"$archivo"_conErrores".txt –Append
        }
      }
      else {
        #Write-Host "Hora erronea: " $_
        $_ | Out-File -FilePath $tempArch7\"temp_"$archivo"_conErrores".txt –Append
      }
    }
    else {
      #Write-Host "Fecha erronea: " $_
      $_ | Out-File -FilePath $tempArch7\"temp_"$archivo"_conErrores".txt –Append
    }
  }
}


$tempArch1 = New-Item "tempArch1" -itemType Directory
$tempArch2 = New-Item "tempArch2" -itemType Directory
$tempArch3 = New-Item "tempArch3" -itemType Directory
$tempArch4 = New-Item "tempArch4" -itemType Directory
$tempArch5 = New-Item "tempArch5" -itemType Directory

# Proceso cada archivo. Se genera un archivo ordenado por usuario
#Get-ChildItem $directorio -File | ForEach-Object {
Get-ChildItem $tempArch6 -File | ForEach-Object {
  $archivo = $_.Name

  # Proceso cada linea leida de un archivo. 
  Get-Content $_ | ForEach-Object {
    $fecha = ($_ | Select-String -Pattern '\w+-\w+-\w+' | ForEach-Object { $_.Matches.value })
    $horaUsuario = ($_ | Select-String -Pattern '\w+:\w+:\w+-\w+' | ForEach-Object { $_.Matches.value })
    $hora = $horaUsuario.Split("-")[0]
    $usuario = $horaUsuario.Split("-")[1]
    
    $item = New-object psobject 
    $item | Add-Member -MemberType NoteProperty -Name "Usuario" -Value $usuario
    $item | Add-Member -MemberType NoteProperty -Name "Fecha" -Value $fecha
    $item | Add-Member -MemberType NoteProperty -Name "Hora" -Value $hora
    $item | Add-Member -MemberType ScriptMethod -Name "GetName" -Value { $this.Usuario + ' ' + $this.Fecha + ' ' + $this.Hora }
    
    $item.GetName()  | Out-File -FilePath $tempArch1\"temp_"$archivo"_salida".txt –Append
  } 

  Get-Content $tempArch1\"temp_"$archivo"_salida".txt | Sort-Object | Out-File -FilePath $tempArch2\"temp_"$archivo"_ordenado".txt

  # eliminar las líneas duplicadas del archivo
  Get-Content -Path $tempArch2\"temp_"$archivo"_ordenado".txt | Select-Object -Unique | Set-Content -Path $tempArch3\"temp_"$archivo"_lineasUnicas".txt # Save

  # validamos que todos tengan su par y lo unimos en una sola linea con la diferencia en segundos al final
  $FILE = Get-Content -Path $tempArch3\"temp_"$archivo"_lineasUnicas".txt
  $regAnt = "vacio"
  $userAnt = "vacio"
  $totalTiempo = 0
  $contador = 0
  foreach ($LINE in $FILE) {
    $regAct = $LINE
    $userAct = $LINE.Split(" ")[0]
    if ($userAct -eq $userAnt) {
      $horaAnt = $regAnt.Split(" ")[1].Replace('-', '/') + " " + $regAnt.Split(" ")[2]
      $horaAct = $regAct.Split(" ")[1].Replace('-', '/') + " " + $regAct.Split(" ")[2]
      $difTiempo = ((Get-Date $horaAct) - (Get-Date $horaAnt))
      $totalTiempo += $difTiempo.TotalSeconds
      $contador += 1
      $regAntAct = $regAnt + " " + $regAct + " " + $difTiempo.TotalSeconds
      $regAntAct | Out-File -FilePath $tempArch4\"temp_"$archivo"_pares".txt –Append
      $regAnt = "vacio"
      $userAnt = "vacio"
      $regAct = " "
      $userAct = " "
    }
    else {
      $regAnt = $regAct
      $userAnt = $userAct
    }
  }
}

# Cuántas llamadas no superan la media de tiempo por día
Get-ChildItem $tempArch4 -File | ForEach-Object {
  $totalNoSupera = 0
  $hash1 = @{};
  $hash2 = @{}; 
  $FILE = Get-Content $_
  $totalTiempo = 0
  $cuento = 0
  foreach ($LINE in $FILE) {
    $totalTiempo += $LINE.Split(" ")[6]
    $cuento += 1
    $tiempoLlamada = $LINE.Split(" ")[6]

    $tiempoAct = $LINE.Split(" ")[6]
    $userAct = $LINE.Split(" ")[0]
   
    $tiempo = [int] $hash1[$userAct]
    if ($tiempo -gt 0) {
      $tiempo += [int] $tiempoAct
      $hash1.Set_Item($userAct, $tiempo )
      $contador = $hash2[$userAct]
      $contador += 1
      $hash2.Set_Item($userAct, $contador )
    }
    else {
      $cont = 1
      $hash1.Add($userAct, $tiempoAct )
      $hash2.Add($userAct, $cont )
    }     
  }
  Write-Host " "
  $fecha = $LINE.Split(" ")[1]
  Write-Host "Fecha: " $fecha
  $promedio = $totalTiempo / $cuento
  $totalTiempo = 0
  $contador = 0
  Write-Host "Promedio de tiempo y cantidad por usuario por día: "
  foreach ($key in $hash1.Keys) {
    $totalLlamada = $hash1[$key]
    $cantLlamada = $hash2[$key]

    $promedioUser = $totalLlamada / $cantLlamada
    Write-Host "    Usuario: "  $key  " - promedio tiempo: "  $promedioUser  " - cantidad: "  $cantLlamada

  }
  $totalNoSupera = 0
  foreach ($LINE in $FILE) {
    $tiempoLlamada = [Int]$LINE.Split(" ")[6]

    if ( $tiempoLlamada -lt $promedio ) { 
      $totalNoSupera += 1
    }
  }

  Write-Host "Promedio de tiempo de las llamadas realizadas por día: " $promedio
  Write-Host "cantidad llamadas que no superan la media de tiempo por día: " $totalNoSupera
  $totalNoSupera = 0
}

# unificamos en un solo archivo para obtener los montos semanales
Get-ChildItem $tempArch4 -File | ForEach-Object {
  Get-Content $_ | Out-File -FilePath $tempArch5\"temp_semanal".txt –Append
}

Get-ChildItem $tempArch5 -File | ForEach-Object {
  $hash2 = @{};
  $contador2 = 0 
  $promedioSemanal = 0
  $FILE = Get-Content $_
  foreach ($LINE in $FILE) {
    $userAct = $LINE.Split(" ")[0]
    $contador = $hash2[$userAct]
    $contador += 1
    $hash2.Set_Item($userAct, $contador )
    $tiempoAct = [Int]$LINE.Split(" ")[6]
    $sumTiempo += $tiempoAct
    $contador2 += 1
  }
  
  $promedioSemanal = $sumTiempo / $contador2
  Write-Host " "
  Write-Host "Los 3 usuarios con más llamadas en la semana: "
  $hash2.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 3

  $hash1 = @{};
  foreach ($LINE in $FILE) {
    $userAct = $LINE.Split(" ")[0]
    $tiempoAct = [Int]$LINE.Split(" ")[6]
    
    if ($tiempoAct -lt $promedioSemanal) {
      $contador = $hash1[$userAct]
      $contador += 1
      $hash1.Set_Item($userAct, $contador )
    }
  }
  Write-Host "El usuario que tiene más cantidad de llamadas por debajo de la media en la semana: (media semanal " $promedioSemanal")"
  $hash1.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 1
}

# Muestro registros erroneos
Write-Host "  "
Write-Host "Se listan los registros erroneos: "
Get-ChildItem $tempArch7 -File | ForEach-Object {
  Get-Content $_ 
}

Remove-Item -Path temp* -Recurse
