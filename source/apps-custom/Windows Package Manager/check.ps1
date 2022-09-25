#Get WinGet Path (system)
$ResolveWingetPath = Resolve-Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
if ($ResolveWingetPath) {
    #If multiple versions (when pre-release versions are installed), pick last one
    $WingetPath = $ResolveWingetPath[-1].Path
    $Script:Winget = "$WingetPath\winget.exe"

    if($([System.Diagnostics.FileVersionInfo]::GetVersionInfo($Winget).FileVersion) -ge [System.Version]$ProgramVersion_minimum){
        Write-Host "Found it!"
    }
}
