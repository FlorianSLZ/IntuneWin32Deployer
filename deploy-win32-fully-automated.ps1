#Requires -Modules IntuneWin32App, PSIntuneAuth, AzureAD
<#
    .SYNOPSIS
        Packages the latest 1Password for MEM (Intune) deployment.
        Uploads the mew package into the target Intune tenant.
    .NOTES
        For details on IntuneWin32App go here: https://github.com/MSEndpointMgr/IntuneWin32App/blob/master/README.md
    
    .PARAMETER Path
    Path to use for downloading and processing packages
    .PARAMETER PackageOutputPath
    Path to export the created packages
    .PARAMETER TenantName
    Microsoft Endpoint Manager (Intune) Azure Active Directory Tenant. This should be in the format of Organization.onmicrosoft.com
    .EXAMPLE
    .\Update-1PasswordPackage.ps1 -Upload
    
    This will create a new package using the default values
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $RepoPath = "$PSScriptRoot",

    [Parameter(Mandatory = $False)]
    [System.String] $TenantName,

    [Parameter(Mandatory = $False)]
    [System.String] $IntuneWinAppUtil_online = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe",  

    [switch]$Force
    
)

# Basic variables

function Read-AppRepo{
    #https://winget.run/
    $AppRepo = Import-CSV -Path ".\Applications.csv" 
    return $AppRepo  

}

function Create-WingetWin32App($Prg){
    # Set and creat program folder
    $Prg_Path = "$RepoPath\winget\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content ".\template\winget\install.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1"

    # create uninstall file
    $(Get-Content ".\template\winget\uninstall.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"

    # create validation file
    $(Get-Content ".\template\winget\check.ps1").replace("WINGETPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1"

    # Create intunewin
    Create-Win32_intunewin $Prg $Prg_Path
}

function Create-ChocoWin32App($Prg){
    # Set and creat program folder
    $Prg_Path = "$RepoPath\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content ".\template\choco\install.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1"

    # create param file
    if($Prg.parameter){New-Item -Path "$Prg_Path\param.txt" -ItemType "file" -Force -Value $Prg.parameter}

    # create uninstall file
    $(Get-Content ".\template\choco\uninstall.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"

    # create validation file
    $(Get-Content ".\template\choco\check.ps1").replace("CHOCOPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1"

    # check appliaction name and set if not present
    if(!$Prg.name){
        $ChocoDetails = '(' + $((choco search $Prg.name --by-id-only --exact -v) -join '|') + ')'
        $pos = $ChocoDetails.IndexOf("Title:")
        $ChocoDescriptionPlus = $ChocoDetails.Substring($pos+7)
        $pos = $ChocoDescriptionPlus.IndexOf(" |")
        $Prg.name = $ChocoDescriptionPlus.Substring(0, $pos)
    }

    # check appliaction description and set if not present
    if(!$Prg.Description){
        $ChocoDetails = '(' + $((choco search $Prg.name --by-id-only --exact -v) -join '|') + ')'
        $pos = $ChocoDetails.IndexOf("Description:")
        $ChocoDescriptionPlus = $ChocoDetails.Substring($pos+13)
        $pos = $ChocoDescriptionPlus.IndexOf("|")
        $Prg.Description = $ChocoDescriptionPlus.Substring(0, $pos)
    }

    # Create intunewin
    Create-Win32_intunewin $Prg $Prg_Path
}

function Create-Win32_intunewin($Prg, $Prg_Path) {
    # download newest IntuneWinAppUtil
    Invoke-WebRequest -Uri $IntuneWinAppUtil_online -OutFile "$RepoPath\IntuneWinAppUtil.exe" -UseBasicParsing
    # create intunewin file
    Start-Process "$RepoPath\IntuneWinAppUtil.exe" -Argument "-c $Prg_Path -s install.ps1 -o $Prg_Path -q" -Wait -NoNewWindow
}

function Upload-Win32App{

}

$Prg_selection = Read-AppRepo | Out-GridView -OutputMode Multiple -Title "Select Applications to create and upload"

foreach($Prg in $Prg_selection){
    Create-WingetWin32App $Prg
}