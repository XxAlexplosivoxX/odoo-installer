Import-Module bitstransfer
$pythonVersion = python --version
clear
Write-Host "
             __               _            __        ____   _____           _       __ 
  ____  ____/ /___  ____     (_)___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
 / __ \/ __  / __ \/ __ \   / / __ \/ ___/ __/ __  / / /   \__ \/ ___/ ___/ / __ \/ __/
/ /_/ / /_/ / /_/ / /_/ /  / / / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_  
\____/\__,_/\____/\____/  /_/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/  
                                                                         /_/           
   ___          ___   __                 __         _         
  / _ )__ __   / _ | / /____ __    ___  / /__  ___ (_)  _____ 
 / _  / // /  / __ |/ / -_) \ /   / _ \/ / _ \(_-</ / |/ / _ \
/____/\_, /  /_/ |_/_/\__/_\_\___/ .__/_/\___/___/_/|___/\___/
     /___/                  /___/_/                           

" -ForegroundColor Cyan

# Declara una función para descargar los instaladores
function Downloader {
    # Declara los parametros de la función marcandolos como requeridos
    param (
        [Parameter(Mandatory=$true)]
        [String]$Url,
        [Parameter(Mandatory=$true)]
        [String]$Filename
    )
    
    $destination = -join($HOME,"\",$Filename)
    # En la variable result se guarda la referencia al objeto creado por el proceso de transferencia de bits 
    # generado por el método Start-Bitstransfer
    Write-Host $destination
    $result = Start-BitsTransfer -Source $Url -Destination $destination -TransferType Download -Asynchronous
    $isDownloadFinished = $false;

    # El bucle finaliza hasta que se complete la descarga
    # (mientras la variable $isDownloadFinished no contenga el valor booleano true)
    While ($isDownloadFinished -ne $true) {
        sleep 0.01

        # Guarda en la varable $jobstate el estado del proceso en una cadena de texto
        # retornado del metodo JobState que se encuentra dentro del objeto referenciado la variable $result
        $jobstate = $result.JobState;
        if($jobstate.ToString() -eq "Transferred") { $isDownloadFinished = $true }
        $percentComplete = ($result.BytesTransferred / $result.BytesTotal) * 100
        Write-Progress -Activity ("Downloading " + $Filename +"... " + $result.BytesTransferred + " bytes (" +  [math]::Round((($result.BytesTransferred / 1024) / 1024),1) + " Mb)" + " / " +  [math]::Round((($result.BytesTotal / 1024) / 1024),1) + " Mb total") -PercentComplete $percentComplete
    }
    Write-Progress -Activity ("Downloading " + $Filename +"... " + $result.BytesTransferred + " bytes (" +  [math]::Round((($result.BytesTransferred / 1024) / 1024),1) + " Mb)" + " / " +  [math]::Round((($result.BytesTotal / 1024) / 1024),1) + " Mb total") -Completed
    # Get-BistTransfer retorna los procesos de transferencia de bits que se hayan hecho para que luego
    # Complete-BitsTransfer marque como completada la transferencia de bits y se guarde el archivo 
    Get-BitsTransfer | Complete-BitsTransfer
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
            Write-Host "[!] - The input must be not empty!!." -ForegroundColor Red
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
            Write-Host "[!] - '$postgresqlPATH' doesn't exist!!." -ForegroundColor Red
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
            Write-Host "[!] - Don't match with any version!!" -ForegroundColor Red
        }
    }
}

Write-Host "[+] - Downloading..." -ForegroundColor Green
$url =  -join("https://nightly.odoo.com/",$odooVersion,"/nightly/windows/odoo_",$odooVersion,".latest.exe")
Downloader -Url $url -Filename "odoo-installer.exe"
Write-Host "[+] - Executing..." -ForegroundColor Green
$DentinationOdoo = "$env:USERPROFILE\odoo-installer.exe"
Start-Process -Wait -FilePath $DestinationOdoo
Write-Host "[+] - Odoo is succesfully installed :D !!." -ForegroundColor Green
