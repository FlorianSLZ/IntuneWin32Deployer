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

#   Copy Files & Folders
New-Item $ProgramPath -type Directory -Force
Copy-Item $($(Split-Path $MyInvocation.MyCommand.Path) + "\" + "source\*") $ProgramPath -Force -Recurse
Get-Childitem -Recurse $ProgramPath | Unblock-file	

#   Create Startmenu shortcut
Copy-Item "$ProgramPath\Intune Win32 Deployer.lnk" "$env:appdata\Microsoft\Windows\Start Menu\Programs\Intune Win32 Deployer.lnk" -Force -Recurse

