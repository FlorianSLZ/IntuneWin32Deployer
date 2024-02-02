#############################################################################################################
#
#   Tool:       IntuneWin32 Deployer - Installer
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
    $targetPath = "$IWDPath\start.cmd"
    $shortcutPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\IntuneWin32Deployer.lnk")
    $iconPath = "$IWDPath\templates\IntuneWin32Deployer.ico"

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.IconLocation = $iconPath
    $Shortcut.Save()

    Write-Host "Installation completed!" -ForegroundColor green



}catch{$_}

try{
    # check if module IntuneWin32Deployer is present
    $Module = "IntuneWin32Deployer"
    if (Get-Module -ListAvailable -Name $Module) {
        Write-Host "Module exists"
    } else {
        Write-Host "Please Install the Module $Module by running: "
        Write-Host "Install-Module $Module" -ForegroundColor Cyan
    }
}catch{$_}

# Enter to exit
Read-Host "Press [Enter] to close"