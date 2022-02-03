function Read-WingetRepo{
    #https://winget.run/
    [xml]$WingetRepo = Get-Content -Path ".\wingetApps.xml"
    return $WingetRepo.programs.prg  

}

function Write-WingetRepo{
    $Apps = Read-WingetRepo
    
}

function Create-WingetWin32App($Prg){
    # Set and creat program folder
    $Prg_Path = ".\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content ".\template\install.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1"

    # create uninstall file
    $(Get-Content ".\template\uninstall.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"

    # create validation file
    $(Get-Content ".\template\check.ps1").replace("WINGETPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1"

    # Create intunewin
    .\template\IntuneWinAppUtil.exe -c $Prg_Path -s install.ps1 -o $Prg_Path -q
}

function Upload-WingetWin32App{

}

$Prg_selection = Read-WingetRepo | Out-GridView -OutputMode Multiple -Title "Select Applications to create"

foreach($Prg in $Prg_selection){
    Create-WingetWin32App $Prg
}