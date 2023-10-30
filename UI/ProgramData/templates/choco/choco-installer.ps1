$localprograms = C:\ProgramData\chocolatey\choco.exe list
if ($localprograms -like "*$AppInfo.id*"){
    C:\ProgramData\chocolatey\choco.exe upgrade $AppInfo.id -y
}else{
    C:\ProgramData\chocolatey\choco.exe install $AppInfo.id -y
}