$localprograms = C:\ProgramData\chocolatey\choco.exe list
if ($localprograms -like "*$AppInfo.id*"){
    C:\ProgramData\chocolatey\choco.exe upgrade $AppInfo.id -y
}else{
    C:\ProgramData\chocolatey\choco.exe install $AppInfo.id -y
}





# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1){
        $winget_exe = $winget_exe[-1].Path
}

if (!$winget_exe){Write-Error "Winget not installed"}

& $winget_exe install --exact --id $AppInfo.id --silent --accept-package-agreements --accept-source-agreements $param