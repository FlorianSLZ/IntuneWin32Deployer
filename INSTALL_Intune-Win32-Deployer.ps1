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
Write-Host "Checking / installing Modules..."

$Modules_needed = "MSAL.PS", "IntuneWin32App"#, "AzureAD"

try{  
    foreach($Module in $Modules_needed){
        if (!$(Get-Module -ListAvailable -Name $Module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Module: $Module"
        Install-Module $Module -Scope CurrentUser -Force
        }
    }
}catch{$_}

try{
    # temporarry fix for IntuneWin32App module
    $oldLine = '$ScriptContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.IO.File]::ReadAllBytes("$($ScriptFile)") -join [Environment]::NewLine))'
    $newLine = '$ScriptContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$($ScriptFile)"))'
    $File = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Modules\IntuneWin32App\1.3.3\Public\New-IntuneWin32AppDetectionRuleScript.ps1"
    (Get-Content $File).Replace($oldLine,$newLine) | Set-Content $File
}catch{Write-Host "Unable to implement fix for detectionrule. " -ForegroundColor red}


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
$enter2end = Read-HOst "Press [Enter] to close"