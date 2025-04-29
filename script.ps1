Import-Module bitstransfer
$pythonVersion = python --version
clear
Write-Host "
01101000 01101111 01101100 01100001 01111000 01100100 01111000 01111000 01100100 01111000 01100100 01100100
   ____      __               ____           __        ____   ____  _____                   _       __ 
  / __ \____/ /___  ____     /  _/___  _____/ /_____ _/ / /  / __ \/ ___/   _______________(_)___  / /_
 / / / / __  / __ \/ __ \    / // __ \/ ___/ __/ __ '/ / /  / /_/ /\__ \   / ___/ ___/ ___/ / __ \/ __/
/ /_/ / /_/ / /_/ / /_/ /  _/ // / / (__  ) /_/ /_/ / / /  / ____/___/ /  (__  ) /__/ /  / / /_/ / /_  
\____/\__,_/\____/\____/  /___/_/ /_/____/\__/\__,_/_/_/  /_/    /____/  /____/\___/_/  /_/ .___/\__/  
                                                                                         /_/           
01100101 01110100 01101111 01100101 01110011 01101111 01101100 01101111 01100100 01100101 01100011 01101111 

By: XxAlex_plosivoxX

01101110 01101111 01101010 01101111 01100100 01100001
" -ForegroundColor Cyan

# Declara una función para descargar los instaladores
function Downloader {
    <#
    Descarga un archivo desde una URL utilizando BitsTransfer.
    
    .PARAMETER Url
        Cadena con la URL del archivo a descargar.
    
    .PARAMETER Filename
        Nombre con el que se guardará el archivo (se descargará en el directorio HOME del usuario).
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [String]$Url,
        [Parameter(Mandatory=$true)]
        [String]$Filename
    )

    # Elimina procesos de tranferencia de bits para evitar confictos
    Get-BitsTransfer | Remove-BitsTransfer -Confirm:$false

    # Guarda como una cadena el dictorio en donde se guardará el archivo al ser decargado
    $destination = Join-Path -Path $HOME -ChildPath $Filename
    
    try {
        <#
        en la variable result se guarda un objeto que hace referencia 
        al proceso de tranferencia de bits iniciado con el método Start-BitsTransfer

        #> 
        $result = Start-BitsTransfer -Source $Url -Destination $destination -TransferType Download -Asynchronous
    } catch {
        <#
        en el caso que por alguna extraña razón falle, muestra el error.

        Al imprimir en pantalla "[!] - Error initiating transfer: $_"
        incluye el contenido de la variable automática $_, que en el contexto
        de catch contiene información sobre el error que se ha producido.

        $_ Es una de las muchas variables automáticas que exiten en PowerShell,
        #>
        Write-Error "[!] - Error initiating transfer: $_"
        # El return es pa salir de la función, no retorna nada :D
        return
    }
    
    # inicializo la variable que indica si la descarga se ha completao
    $isDownloadFinished = $false;

    while (-not $isDownloadFinished) {
        # cada milésima de segundo
        sleep 0.01
        <#
        guardará el estado de la transferencia de bits dentro de la variable jobstate (estadodelachamba)


        #>
        $jobstate = $result.JobState
        if ($jobstate.ToString() -eq "Transferred") {
            $isDownloadFinished = $true
        }
        $percentComplete = ($result.BytesTransferred / $result.BytesTotal) * 100
        $downloadedMb = [math]::Round((($result.BytesTransferred / 1024) / 1024), 1)
        $totalMb      = [math]::Round((($result.BytesTotal / 1024) / 1024), 1)
        $progressMessage = "Downloading $Filename... $($result.BytesTransferred) bytes ($downloadedMb Mb / $totalMb Mb total)"
        Write-Progress -Activity $progressMessage -PercentComplete $percentComplete
    }

    Write-Progress -Activity "Downloading $Filename" -Completed

    try {
        $result | Complete-BitsTransfer
        Write-Host "[!] - Download complete: $destination"
    } catch {
        Write-Error "[!] - Error: $_"
    }
}


$IsNecesaryReboot = $false

if ( $pythonVersion -like '*Python 3.*' ) {
    Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
} else {
    Write-Host "[!] - Python has not been installed" -ForegroundColor Red
    if ( Test-Path -Path "$env:USERPROFILE\python-3.13.2-amd64.exe" ) {
        Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
        Write-Host "[+] - Executing..." -ForegroundColor Green
        $DestinationPython = "$env:USERPROFILE\python-3.13.2-amd64.exe"
        Start-Process -Wait -Filepath $DestinationPython
        Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
    } else {
        Write-Host "[+] - Downloading..." -ForegroundColor Green
        Downloader -Url "https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe" -Filename "python-3.13.2-amd64.exe"
        Write-Host "[+] - Installing..." -ForegroundColor Green
        $DestinationPython = "$env:USERPROFILE\python-3.13.2-amd64.exe"
        Start-Process -Wait -Filepath $DestinationPython
        Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
    }
    $IsNecesaryReboot = $true
}

while($true) {
    $iscppInstalled = Read-Host "[?] - Do you have installed c++ build tools? (yY/nN)"
    $verification = (($iscppInstalled -contains "y") -and ($iscppInstalled -contains "Y"))

    if (!$verification) {
        if ( Test-Path -Path ("$env:USERPROFILE\"+"vs_BuildTools.exe") ) {
            Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
            Write-Host "[+] - Executing..." -ForegroundColor Green
            $DestinationCpp = "$HOME\vs_BuildTools.exe"
            Write-Host $DestinationCpp
            Start-Process -Wait -Filepath $DestinationCpp
            Write-host "[!] - OK..." -ForegroundColor Green
            break
        } else {
            Write-Host "[+] - Downloading..." -ForegroundColor Green
            Downloader -Url "https://aka.ms/vs/17/release/vs_BuildTools.exe" -Filename "vs_BuildTools.exe"
            Write-Host "[+] - Executing..." -ForegroundColor Green
            $DestinationCpp = "$HOME\vs_BuildTools.exe"
            Write-Host $DestinationCpp
            Start-Process -Wait -Filepath $DestinationCpp
            Write-host "[!] - OK..." -ForegroundColor Green
            break
        }
        $IsNecesaryReboot = $true
    } else {
        Write-host "[!] - OK..." -ForegroundColor Green
        break
    }
}

while($true) {
    $isPostgresqlInstalled = Read-Host "[?] - Do you have installed PostgreSQL? (yY/nN)"
    $verification = (($isPostgresqlInstalled -contains "y") -and ($isPostgresqlInstalled -contains "Y"))

    if ($verification) {
        $postgresqlPATH = Read-Host "[?] - Please enter the bin directory of you PostgreSQL instalation"
        if (!$postgresqlPATH) {
            Write-Error "[!] - The input must be not empty!!."
        } elseif ( Test-Path -Path $postgresqlPATH ) {
            Write-Host "[+] - directory '$postgresqlPATH' for PostgreSQL exist!..." -ForegroundColor Green
            if ( $env:PATH -contains $postgresqlPATH ) {
                Write-Host "[+] - $postgresqlPATH it's already added to PATH" -ForegroundColor Green
                break
            } else {
                Write-Host "[+] - Adding $postgresqlPATH to PATH" -ForegroundColor Blue
                [System.Environment]::SetEnvironmentVariable("Path", "$env:PATH;$postgresqlPATH", "User")
                Write-Host "[+] - $postgresqlPATH added to PATH" -ForegroundColor Green
                break
            }
        } else {
            Write-Error "[!] - '$postgresqlPATH' doesn't exist!!."
        }
    } else {
        if ( Test-Path -Path "$env:USERPROFILE\postgresql-installer.exe" ) {
            Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
            Write-Host "[+] - Executing..." -ForegroundColor Green
            $DestinationPostgre = "$env:USERPROFILE\postgresql-installer.exe"
            Start-Process -Wait -Filepath $DestinationPostgre
            Write-host "[!] - OK..." -ForegroundColor Green
        } else {
            Write-Host "[+] - Downloading..." -ForegroundColor Green
            Downloader -Url "https://sbp.enterprisedb.com/getfile.jsp?fileid=1259402"  -Filename "postgresql-installer.exe"
            Write-Host "[+] - Executing..." -ForegroundColor Green
            $DestinationPostgre = "$env:USERPROFILE\postgresql-installer.exe"
            Start-Process -Wait -Filepath $DestinationPostgre
            Write-host "[!] - OK..." -ForegroundColor Green
        }
    }
}

if ($IsNecesaryReboot) {
    Write-host "[!] - Restarting in 5 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Restart-Computer
}

Write-Host "[?] - Versions for odoo:"
Write-Host "[1] -> odoo 18 #recomended" -ForegroundColor Cyan
Write-Host "[2] -> odoo 17"
Write-Host "[3] -> odoo 16"
$iteration = $true
while($iteration) {
    $versionSelection = Read-Host "[?] - Select the version to install odoo (select 1, 2 or 3)"

    switch($versionSelection) {
        1 {
            $odooVersion = "18.0"
            $iteration = $false
            break
        }
        2 {
            $odooVersion = "17.0"
            $iteration = $false
            break
        }
        3 {
            $odooVersion = "16.0"
            $iteration = $false
            break
        }
        default {
            Write-Error "[!] - Don't match with any version!!"
        }
    }
}

Write-Host "[+] - Downloading..." -ForegroundColor Green
$url =  -join("https://nightly.odoo.com/",$odooVersion,"/nightly/windows/odoo_",$odooVersion,".latest.exe")
Downloader -Url $url -Filename "odoo-installer.exe"
Write-Host "[+] - Executing..." -ForegroundColor Green
Start-Process -Wait -FilePath "odoo-installer.exe"
Write-Host "[+] - Odoo is succesfully installed :D !!." -ForegroundColor Green
