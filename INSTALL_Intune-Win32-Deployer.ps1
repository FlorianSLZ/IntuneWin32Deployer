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
    Write-Host "Creating / updating startmenu shortcut..."
    Copy-Item "$ProgramPath\Intune Win32 Deployer.lnk" "$env:appdata\Microsoft\Windows\Start Menu\Programs\Intune Win32 Deployer.lnk" -Force -Recurse
    Write-Host "Startmenu item completed" -ForegroundColor green

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

    if(!$(Test-Path $Settings_XML_Path)){
        New-Item -Path $Settings_XML_Path -Type File -Force | Out-Null
    }

    $SettingsCurrent = New-Object -TypeName psobject

    try{
        $SettingsCurrent = Import-Clixml -Path $Settings_XML_Path
        $SettingsCurrent_Members = $(Get-Member -InputObject $SettingsCurrent -ErrorAction Stop).Name
    }catch{}

    if($SettingsCurrent_Members -notcontains "Tenant"){ $SettingsCurrent | Add-Member -NotePropertyName "Tenant" -NotePropertyValue "xxx.onmicrosoft.com" }
    if($SettingsCurrent_Members -notcontains "Publisher"){ $SettingsCurrent | Add-Member -NotePropertyName "Publisher" -NotePropertyValue "scloud" }
    if($SettingsCurrent_Members -notcontains "intunewinOnly"){ $SettingsCurrent | Add-Member -NotePropertyName "intunewinOnly" -NotePropertyValue $False }
    if($SettingsCurrent_Members -notcontains "PRupdater"){ $SettingsCurrent | Add-Member -NotePropertyName "PRupdater" -NotePropertyValue $False }
    if($SettingsCurrent_Members -notcontains "AADgrp"){ $SettingsCurrent | Add-Member -NotePropertyName "AADgrp" -NotePropertyValue $False }
    if($SettingsCurrent_Members -notcontains "AADuninstallgrp"){ $SettingsCurrent | Add-Member -NotePropertyName "AADuninstallgrp" -NotePropertyValue $False }
    if($SettingsCurrent_Members -notcontains "AADgrpPrefix"){ $SettingsCurrent | Add-Member -NotePropertyName "AADgrpPrefix" -NotePropertyValue "APP-WIN-" }
    
    Export-Clixml -Path $Settings_XML_Path -InputObject $SettingsCurrent -Force | Out-Null



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
    if ($(Get-Module -ListAvailable -Name "IntuneWin32App" -ErrorAction SilentlyContinue).Version -notcontains [version]$("1.3.5")) {
        Write-Host "Installing Module: IntuneWin32App"
        Install-Module "IntuneWin32App" -RequiredVersion 1.3.5 -Scope CurrentUser -Force
    }
    if (!$(Get-Module -ListAvailable -Name "Microsoft.Graph.Groups" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Module: Microsoft.Graph.Groups"
        Install-Module "Microsoft.Graph.Groups" -Scope CurrentUser -Force
    }
}catch{$_}


#############################################################################################################
#   Chocolatey & Windows Package Manager
#############################################################################################################

try{
    $install_choco = Read-Host "Do you want to install chocolatey? (Needed to create chocolatey packages) [Y/N]"
    $install_winget = Read-Host "Do you want to install the Windows Package Manager? (Needed to create winget packages) [Y/N]"

    if(($install_choco -eq "y") -or ($install_winget -eq "y")){
        # Prerequirements (Chocolatey and winget)
        . ".\source\ressources\prerequirements_AsAdmin.ps1" -choco $(if($install_choco -eq "y"){$true}else{$false}) -winget $(if($install_winget -eq "y"){$true}else{$false})
    }
}catch{$_}


# Enter to exit
Write-Host "Installation completed!" -ForegroundColor green
Read-Host "Press [Enter] to close"