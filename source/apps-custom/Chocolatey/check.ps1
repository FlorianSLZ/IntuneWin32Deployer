$ProgramName = "Chocolatey"

$localprograms = C:\ProgramData\chocolatey\choco.exe list
if ($localprograms -like "*$ProgramName*"){
    Write-Host "Found it!"
}else{
    Write-Host "Not Found!"
    exit 1618 
}

