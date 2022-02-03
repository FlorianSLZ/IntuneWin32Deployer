$ProgramName = "WindowsPackageManager"
$ProgramPath = "C:\Program Files\PRPOGRAM\start.exe"
$ProgramVersion_minimum = '1.16.12652.0'
$ProgramVersion_current = (Get-AppPackage -Name "Microsoft.DesktopAppInstaller").Version
$InstallationOK = [System.Version]$ProgramVersion_current -gt [System.Version]$ProgramVersion_minimum

if($InstallationOK -eq $true){
    Write-Host "Found it!"
}




