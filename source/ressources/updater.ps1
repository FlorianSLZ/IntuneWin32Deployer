#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Updater
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
    Copy-Item "$ProgramPath\updatedata\Intune-Win32-Deployer-main\source\*" $ProgramPath -Force -Recurse
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

}catch{$_}


#############################################################################################################
#   Modules
#############################################################################################################
Write-Host "Checking / installing Modules..."

$Modules_needed = "MSAL.PS", "IntuneWin32App"

try{  
    foreach($Module in $Modules_needed){
        if (!$(Get-Module -ListAvailable -Name $Module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Module: $Module"
        Install-Module $Module -Scope CurrentUser -Force
        }
    }
}catch{$_}

try{
    # temporarry fix for IntuneWin32App Module
	$IntuneWin32App_usr = "$([Environment]::GetFolderPath(""MyDocuments""))\WindowsPowerShell\Modules\IntuneWin32App\1.3.3"
	$IntuneWin32App_sys = "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.3.3"
    $oldLine = '$ScriptContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.IO.File]::ReadAllBytes("$($ScriptFile)") -join [Environment]::NewLine))'
    $newLine = '$ScriptContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$($ScriptFile)"))'
	if(Test-Path $IntuneWin32App_usr){
        $File = "$IntuneWin32App_usr\Public\New-IntuneWin32AppDetectionRuleScript.ps1"
        if($(Get-Content $File) -match 'System.Text.Encoding'){(Get-Content $File).Replace($oldLine,$newLine) | Set-Content $File}
    }
	if(Test-Path $IntuneWin32App_sys){
        $File = "$IntuneWin32App_sys\Public\New-IntuneWin32AppDetectionRuleScript.ps1"
        if($(Get-Content $File) -match 'System.Text.Encoding'){(Get-Content $File).Replace($oldLine,$newLine) | Set-Content $File}
    }
	if($(Test-Path $IntuneWin32App_sys) -or (Test-Path $IntuneWin32App_usr)){}else{Write-Error "Module IntuneWin32App not found!"}
    
    
}catch{
    Write-Host "Unable to implement fix for detectionrule." -ForegroundColor red
    Write-Host "If Module is already installed in System context. Try to execute the installer as Admin" -ForegroundColor yellow
    Read-Host "Press [ENTER] to exit"
    exit
}

# done
Write-Host "Update completed!" -ForegroundColor green
