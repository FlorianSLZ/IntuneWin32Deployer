#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Prerequirements
#   Author:     Florian Salzmann
#   Website:    http://www.scloud.work
#   Twitter:    https://twitter.com/FlorianSLZ
#   LinkedIn:   https://www.linkedin.com/in/fsalzmann/
#
#############################################################################################################


[CmdletBinding()]
Param (

    [Parameter(Mandatory = $False)]
    [bool] $choco = $true,

    [Parameter(Mandatory = $False)]
    [bool] $winget = $true, 

    [switch]$Force
    
)

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 3
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

if($choco -eq $true){
    # Check if chocolatey is installed
    $Check_Chocolatey = try{C:\ProgramData\chocolatey\choco.exe list}catch{}
    if (!$Check_Chocolatey){
        try{
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 
            cls
            Write-Host "Installation of Chocolatey finished" -ForegroundColor green
        }catch{
            Write-Error "Failed to install Chocolatey!"
        } 
    }else{Write-Host "Chocolatey allready installed"}
}

if($winget -eq $true){
    # Check if winget is installed
    $Check_winget = (Get-AppPackage -Name "Microsoft.DesktopAppInstaller")
    if (!$Check_winget){
        Write-Host "Instaling winget (on local machine)"

        $PackageName = "WindowsPackageManager"
        $MSIXBundle = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $URL_msixbundle = "https://aka.ms/getwinget"

        # Program/Installation Folder
        $Folder_install = "$env:temp\$PackageName"
        New-Item -Path $Folder_install -ItemType Directory -Force -Confirm:$false | Out-Null


        # Download current WinGet MSIXBundle
        $wc = New-Object net.webclient
        $wc.Downloadfile($URL_msixbundle, "$Folder_install\$MSIXBundle")  | Out-Null

        # Install WinGet MSIXBundle 
        try{
            Add-AppxProvisionedPackage -Online -PackagePath "$Folder_install\$MSIXBundle" -SkipLicense 
            Write-Host "Installation of Windows Package Manager finished" -ForegroundColor green
        }catch{
            Write-Error "Failed to install $PackageName!"
        } 

        # Install file cleanup
        Start-Sleep 3 # to unblock installation file
        Remove-Item -Path "$Folder_install" -Force -Recurse  | Out-Null



    }else{Write-Host "Winget allready installed"}
}
