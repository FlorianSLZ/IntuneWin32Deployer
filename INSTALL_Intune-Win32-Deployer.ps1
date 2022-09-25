#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Installer
#   Author:     Florian Salzmann
#   Website:    http://www.scloud.work
#   Twitter:    https://twitter.com/FlorianSLZ
#   LinkedIn:   https://www.linkedin.com/in/fsalzmann/
#
#############################################################################################################

#   Program variables
$ProgramPath = "$env:LOCALAPPDATA\Intune-Win32-Deployer"


#############################################################################################################
#   Program files
#############################################################################################################

try{
    #   Copy Files & Folders
    Write-Host "Copying / updating program files..."
    New-Item $ProgramPath -type Directory -Force | Out-Null
    Copy-Item $($(Split-Path $MyInvocation.MyCommand.Path) + "\" + "source\*") $ProgramPath -Force -Recurse
    Get-Childitem -Recurse $ProgramPath | Unblock-file
    Write-Host "Program files completed" -ForegroundColor green

    #   Create Startmenu shortcut
    Write-Host "Creating / updating startmeu shortcut..."
    Copy-Item "$ProgramPath\Intune Win32 Deployer.lnk" "$env:appdata\Microsoft\Windows\Start Menu\Programs\Intune Win32 Deployer.lnk" -Force -Recurse
    Write-Host "Startmeu item completed" -ForegroundColor green

    # create Application.csv if not present
    $Repo_CSV_Path = "$ProgramPath\Applications.csv"
    if(!$(Test-Path $Repo_CSV_Path)){
        $AppRepo = @()
        $AppRepo += New-Object psobject -Property @{Name = "";id = "7zip.7zip"; Description = "";manager = "winget";install = "";uninstall = "";as = "";publisher = "";parameter = "";dependency = ""}
        $AppRepo += New-Object psobject -Property @{Name = "";id = "Microsoft.VisualStudioCode"; Description = "";manager = "winget";install = "";uninstall = "";as = "";publisher = "";parameter = "";dependency = ""}
        $AppRepo | Export-CSV -Path $Repo_CSV_Path -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    }

    # create settings.xml if not present
    $Settings_XML_Path = $ProgramPath + '\ressources\settings.xml'
    $Settings_XML = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <S N="Tenant">xxx.onmicrosoft.com</S>
      <S N="Publisher">scloud</S>
      <S N="intunewinOnly">false</S>
      <S N="PRupdater">false</S>
      <S N="AADgrp">false</S>
      <S N="AADgrpPrefix">APP-WIN-</S>
    </MS>
  </Obj>
</Objs>
'@
    if(!$(Test-Path $Settings_XML_Path)){
        $Settings_XML | Out-File $Settings_XML_Path
    }



}catch{$_}


#############################################################################################################
#   Modules
#############################################################################################################
Write-Host "Checking / installing Modules..."
try{  
    if (!$(Get-Module -ListAvailable -Name "MSAL.PS" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Module: MSAL.PS"
        Install-Module "MSAL.PS" -Scope CurrentUser -Force
    }
    if ($(Get-Module -ListAvailable -Name "IntuneWin32App" -ErrorAction SilentlyContinue).Version -ne "1.3.5") {
        Write-Host "Installing Module: IntuneWin32App"
        Install-Module "IntuneWin32App" -RequiredVersion 1.3.5 -Scope CurrentUser -Force
    }
}catch{$_}


#############################################################################################################
#   Chocolatey & Windows Package Manager
#############################################################################################################

try{
    $install_choco = Read-Host "Do you want to install chocolatey? (Needed to create chocolatey packages) [Y/N]"
    $install_winget = Read-Host "Do you want to install the Windows Package Manager? (Needed to create einget packages) [Y/N]"

    if(($install_choco -eq "y") -or ($install_winget -eq "y")){
        # Prerequirements (Chocolatey and winget)
        . ".\source\ressources\prerequirements_AsAdmin.ps1" -choco $(if($install_choco -eq "y"){$true}else{$false}) -winget $(if($install_winget -eq "y"){$true}else{$false})
    }
}catch{$_}


# Enter to exit
Write-Host "Installation completed!" -ForegroundColor green
Read-Host "Press [Enter] to close"