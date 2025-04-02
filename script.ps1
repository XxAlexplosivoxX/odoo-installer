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

$IsNecesaryReboot = $false

# verifica si python está instalado y su versión de mayor a python 3
if ( $pythonVersion -like '*Python 3.*' ) {
    Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
} else {
    Write-Host "[!] - Python has not been installed" -ForegroundColor Red
    if ( Test-Path -Path "./python-installer.exe" ) {
        Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
        Write-Host "[+] - Executing..." -ForegroundColor Green
        Start-Process -Wait -Filepath "./python-installer.exe"
        Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
    } else {
        Write-Host "[+] - Downloading..." -ForegroundColor Green
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.13.2/python-3.13.2-amd64.exe" -OutFile "./python-installer.exe"
        Write-Host "[+] - Installing..." -ForegroundColor Green
        Start-Process -Wait -Filepath "./python-installer.exe"
        Write-Host "[+] - Python has succesful installed" -ForegroundColor Green
    }
    $IsNecesaryReboot = $true
}

while($true) {
    $iscppInstalled = Read-Host "[?] - Do you have installed c++ build tools? (yY/nN)"
    $verification = (($iscppInstalled -contains "y") -and ($iscppInstalled -contains "Y"))

    if (!$verification) {
        if ( Test-Path -Path "./c++-build-tools-installer.exe" ) {
            Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
            Write-Host "[+] - Executing..." -ForegroundColor Green
            Start-Process -Wait -Filepath "./c++-build-tools-installer.exe"
            Write-host "[!] - OK..." -ForegroundColor Green
            break
        } else {
            Write-Host "[+] - Downloading..." -ForegroundColor Green
            Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_BuildTools.exe"  -OutFile "./c++-build-tools-installer.exe"
            Write-Host "[+] - Executing..." -ForegroundColor Green
            Start-Process -Wait -Filepath "./c++-build-tools-installer.exe"
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
        if ( Test-Path -Path "./postgresql-installer.exe" ) {
            Write-host "[!] - The installer is already downloaded..." -ForegroundColor Green
            Write-Host "[+] - Executing..." -ForegroundColor Green
            Start-Process -Wait -Filepath "./postgresql-installer.exe"
            Write-host "[!] - OK..." -ForegroundColor Green
        } else {
            Write-Host "[+] - Downloading..." -ForegroundColor Green
            Invoke-WebRequest -Uri "https://sbp.enterprisedb.com/getfile.jsp?fileid=1259402"  -OutFile "./postgresql-installer.exe"
            Write-Host "[+] - Executing..." -ForegroundColor Green
            Start-Process -Wait -Filepath "./postgresql-installer.exe"
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

$url =  -join("https://nightly.odoo.com/",$odooVersion,"/nightly/windows/odoo_",$odooVersion,".latest.exe")
Write-Host "[+] - Downloading..." -ForegroundColor Green
Invoke-WebRequest -Uri $url -OutFile "./odoo-installer.exe"
Write-Host "[+] - Executing..." -ForegroundColor Green
Start-Process -Wait -FilePath "./odoo-installer.exe"
Write-Host "[+] - Odoo is succesfully installed :D !!." -ForegroundColor Green