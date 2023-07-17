$ProgramName = "CHOCOPROGRAMID"


$ChocoPrg_Existing = C:\ProgramData\chocolatey\choco.exe list
    if ($ChocoPrg_Existing -like "*$ProgramName*"){
    Write-Host "Found it!"
}