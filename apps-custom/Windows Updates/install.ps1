$PackageName = "Windows-Updates"
$Version = "1"
$HardReboot = $false

$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\$PackageName-install.log" -Force

# Main logic
$needReboot = $false
Write-Host "Installing updates with HardReboot = $HardReboot."

# Load module from PowerShell Gallery
$null = Install-PackageProvider -Name NuGet -Force
$null = Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false

Write-Host "Install Drivers 1/2"
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot | Select Title, KB, Result | Format-Table

Write-Host "Install all Updates"
Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -WindowsUpdate -IgnoreReboot | Select Title, KB, Result | Format-Table

Write-Host "Install Drivers 2/2"
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot | Select Title, KB, Result | Format-Table

$needReboot = (Get-WURebootStatus -Silent).RebootRequired

# Specify return code
if ($needReboot)
{
    Write-Host "Windows Update indicated that a reboot is needed."
}else{
    Write-Host "Windows Update indicated that no reboot is required."
}

New-Item -Path "$Path_4netIntune\Validation\$PackageName" -ItemType "file" -Force -Value $Version

# For whatever reason, the reboot needed flag is not always being properly set.  So we always want to force a reboot.
# If this script (as an app) is being used as a dependent app, then a hard reboot is needed to get the "main" app to
# install.
if ($HardReboot)
{
    Write-Host "Exiting with return code 1641 to indicate a hard reboot is needed."
    Stop-Transcript
    Exit 1641
}else{
    Write-Host "Exiting with return code 3010 to indicate a soft reboot is needed."
    Stop-Transcript
    Exit 3010
}


