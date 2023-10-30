#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Installer
#   Author:     Florian Salzmann
#   Website:    http://www.scloud.work
#   Twitter/X:  https://twitter.com/FlorianSLZ
#   LinkedIn:   https://www.linkedin.com/in/fsalzmann/
#
#############################################################################################################

#   Program variables
$IWDPath = "$env:LocalAppData\IntuneWin32Deployer"
$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer"


#############################################################################################################
#   Program files
#############################################################################################################

try{
    #   Copy Files & Folders
    Write-Host "Copying / updating program files..."
    New-Item $IWDPath -type Directory -Force | Out-Null
    Copy-Item $($(Split-Path $MyInvocation.MyCommand.Path) + "\ProgramData\*") $IWDPath -Force -Recurse
    Get-Childitem -Recurse $IWDPath | Unblock-file
    Write-Host "Program files completed" -ForegroundColor green

    #   Copy Sample Apps
    Write-Host "Copying / updating sample apps..."
    New-Item $RepoPath -type Directory -Force | Out-Null
    Copy-Item $($(Split-Path $MyInvocation.MyCommand.Path) + "\Apps\*") $RepoPath -Force -Recurse
    Get-Childitem -Recurse $RepoPath | Unblock-file
    Write-Host "Sample apps files completed" -ForegroundColor green

    #   Create Startmenu shortcut
    $targetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $arguments = "-noexit -ExecutionPolicy Bypass -File ""$IWDPath\IntuneWin32Deployer-UI.ps1"""
    $shortcutPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\IntuneWin32Deployer.lnk")
    $iconPath = "$IWDPath\templates\IntuneWin32Deployer.ico"

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments = $arguments
    $Shortcut.IconLocation = $iconPath
    $Shortcut.Save()


}catch{$_}

# Enter to exit
Write-Host "Installation completed!" -ForegroundColor green
Read-Host "Press [Enter] to close"