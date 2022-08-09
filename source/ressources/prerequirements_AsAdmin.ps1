# Check if chocolatey is installed
$CheckChocolatey = C:\ProgramData\chocolatey\choco.exe list --localonly
if (!$CheckChocolatey){
    $install_choco = Read-Host "Instaling Chocolatey (on local machine)"
    if($install_choco){Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))}
}

# Check if winget is installed
$CheckWinget = (Get-AppPackage -Name "Microsoft.DesktopAppInstaller")
if (!$CheckChocolatey){
    Write-Host "Instaling WinGet (on local machine)"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
