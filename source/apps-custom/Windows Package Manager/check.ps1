$PackageName = "WindowsPackageManager"
$Package_winget = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$Path_local = "$ENV:Programfiles\_MEM"

#Get WinGet Path (system)
$ResolveWingetPath = Resolve-Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
if ($ResolveWingetPath) {
    #If multiple versions (when pre-release versions are installed), pick last one
    $WingetPath = $ResolveWingetPath[-1].Path
    $Script:Winget = "$WingetPath\winget.exe"

    if($([System.Diagnostics.FileVersionInfo]::GetVersionInfo($Winget).FileVersion) -ge [System.Version]$ProgramVersion_minimum){
        $ProgramVersion_current = Get-Content -Path "$Path_local\Validation\$PackageName"
        if($ProgramVersion_current -eq $Package_winget){
            Write-Host "Found it!"
        }
    }
}
