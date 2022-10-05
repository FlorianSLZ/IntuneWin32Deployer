$PackageName = "WindowsPackageManager"
$Package_winget = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$URL_winget = "https://aka.ms/getwinget"

$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$ProgramName-install.log" -Force

# Force using TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##############################################################################
#   Install winget
##############################################################################
# Program/Installation folder
$Folder_install = "$Path_local\Data\$PackageName"
New-Item -Path $Folder_install -ItemType Directory -Force -Confirm:$false

# Download current winget MSIXBundle
Write-Host "Downloading stabel version of winget from: $($URL_winget)"
$wc = New-Object System.Net.WebClient
$wc.Downloadfile($URL_winget, "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")

# Install WinGet MSIXBundle 
try{
    Add-AppxProvisionedPackage -Online -PackagePath "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense
    Start-Sleep -Seconds 3
    New-Item -Path "$Path_local\Validation\$PackageName" -ItemType "file" -Force -Value $Package_winget
    Write-Host "Installation of $PackageName finished"
}catch{
    Write-Error "Failed to install $PackageName!"
} 

Stop-Transcript
