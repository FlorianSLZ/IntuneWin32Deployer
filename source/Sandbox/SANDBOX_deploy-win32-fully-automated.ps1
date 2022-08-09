# Array of the PowerShell Modules
$PSModules = "IntuneWin32App", "Microsoft.Graph.Intune"

Write-Host "Installing required PS Modules" -ForegroundColor Cyan
# ExecutionPolicy and NuGet
Set-ExecutionPolicy Unrestricted -Force
Install-PackageProvider -Name NuGet -Force

# Install all defined Modules
foreach($Module in $PSModules){
    Write-Host $Module
    Install-Module -Name $Module -Force -Scope CurrentUser
}


# temporarry fix for IntuneWin32App module
$oldLine = '$ScriptContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.IO.File]::ReadAllBytes("$($ScriptFile)") -join [Environment]::NewLine))'
$newLine = '$ScriptContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$($ScriptFile)"))'
$File = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Modules\IntuneWin32App\1.3.3\Public\New-IntuneWin32AppDetectionRuleScript.ps1"
(Get-Content $File).Replace($oldLine,$newLine) | Set-Content $File

# Calling PS Script
Write-Host "Calling deploy-win32-fully-automated.ps1" -ForegroundColor Cyan
cd "C:\Users\WDAGUtilityAccount\Desktop\deploy-win32-fully-automated"
.\deploy-win32-fully-automated.ps1
