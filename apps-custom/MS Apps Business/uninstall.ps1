$PackageName = "MSApps_Business_DE_x64"

$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\uninstall\$PackageName-uninstall.log" -Force

$OfficeUninstallStrings = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where {(($_.DisplayName -like "*Microsoft 365*") -or ($_.DisplayName -like "*Microsoft Office*"))} | Select UninstallString).UninstallString
taskkill /f /im excel.exe
taskkill /f /im winword.exe
taskkill /f /im powerpnt.exe
taskkill /f /im outlook.exe
taskkill /f /im onenote.exe
taskkill /f /im onenotem.exe

ForEach ($UninstallString in $OfficeUninstallStrings) {
    Write-Host $UninstallString
    $UninstallEXE = ($UninstallString -split '"')[1]
    $UninstallArg = ($UninstallString -split '"')[2] + " DisplayLevel=False"
    Start-Process -FilePath $UninstallEXE -ArgumentList $UninstallArg -Wait
}

Stop-Transcript