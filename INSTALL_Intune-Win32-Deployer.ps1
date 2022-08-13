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
    Write-Host "Program files completed" -ForegroundColor green

}catch{$_}


#############################################################################################################
#   Modules
#############################################################################################################

try{

}catch{$_}



#############################################################################################################
#   Chocolatey & Windows Package Manager
#############################################################################################################

try{
    $install_choco = Read-Host "Do you want to install chocolatey? (Needed to create chocolatey packages) [Y/N]"
    $install_winget = Read-Host "Do you want to install the Windows Package Manager? (Needed to create einget packages) [Y/N]"

    # Prerequirements (Chocolatey and winget)
    . ".\source\ressources\prerequirements_AsAdmin.ps1" -choco $(if($install_choco -eq "y"){$true}else{$false}) -winget $(if($install_winget -eq "y"){$true}else{$false})
}catch{$_}


# Enter to exit
$enter2end = Read-HOst "Press [Enter] to close"