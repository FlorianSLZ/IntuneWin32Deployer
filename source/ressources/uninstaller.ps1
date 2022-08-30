#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Uninstaller
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
    #   Remove Files & Folders
    Write-Host "Deliting program files..."
    Remove-Item $ProgramPath -Recurse -Force | Out-Null
    Write-Host "Program files completed" -ForegroundColor green

    #   Remove Startmenu shortcut
    Write-Host "Creating / updating startmeu shortcut..."
    Remove-Item "$env:appdata\Microsoft\Windows\Start Menu\Programs\Intune Win32 Deployer.lnk" -Force -Recurse
    Write-Host "Shortcut removed" -ForegroundColor green

}catch{$_}


#############################################################################################################
#   Modules
#############################################################################################################
Write-Host "Uninstalling Modules..."

$Modules_needed = "MSAL.PS", "IntuneWin32App"#, "AzureAD"

try{  
    foreach($Module in $Modules_needed){
        if ($(Get-Module -ListAvailable -Name $Module -ErrorAction SilentlyContinue)) {
        $ask_yn = Read-Host "Uninstalling Module: $Module ? (Y/N)"
        if($ask_yn -eq "y"){Uninstall-Module $Module -Force}
        $ask_yn = $Null
        }
    }
}catch{$_}


# Enter to exit
Write-Host "Uninstallation completed!" -ForegroundColor green
Read-Host "Press [Enter] to close"