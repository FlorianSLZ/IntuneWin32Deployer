<#Requires -Modules IntuneWin32App, PSIntuneAuth, AzureAD  
#Install-Module IntuneWin32App, PSIntuneAuth, AzureAD  -Scope CurrentUser -Force
<#
    .SYNOPSIS
    Packages choco, winget and custom apps for MEM (Intune) deployment.
    Uploads the packaged into the target Intune tenant.

    .NOTES
    For details on IntuneWin32App go here: https://scloud.work/deploy-win32-fully-automated
    
    .PARAMETER Path
    Path to use for downloading and processing packages

    .PARAMETER PackageOutputPath
    Path to export the created packages

    .PARAMETER TenantName
    Microsoft Endpoint Manager (Intune) Azure Active Directory Tenant. 
    Prefix from yout onmicrosfot.com Domain.
    Ex. scloudwork.onmicrosoft.com --> scloudwork

    .EXAMPLE
    .\deploy-win32-fully-automated.ps1 -TenantName scloudwork
    
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $RepoPath = "$PSScriptRoot",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_choco = "$PSScriptRoot\apps-choco",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_winget = "$PSScriptRoot\apps-winget",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_custom = "$PSScriptRoot\apps-custom",

    [Parameter(Mandatory = $False)]
    [System.String] $TenantName,

    [Parameter(Mandatory = $False)]
    [System.String] $IntuneWinAppUtil_online = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe",  

    [switch]$Force
    
)

function Read-AppRepo{
    $AppRepo = Import-CSV -Path "$RepoPath\Applications.csv" -delimiter ";"
    return $AppRepo  

}

function Create-WingetWin32App($Prg){
    Write-Host "Creat win32 package for $($Prg.id) (Microsoft Package Manager)" -Foregroundcolor cyan

    # Set and create program folder
    $Prg_Path = "$Repo_winget\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content "$RepoPath\template\winget\install.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1"

    # create uninstall file
    $(Get-Content "$RepoPath\template\winget\uninstall.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"

    # create validation file
    $(Get-Content "$RepoPath\template\winget\check.ps1").replace("WINGETPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1"

    # check appliaction name and set if not present
    if(!$Prg.name){
        $WingetDetails = $(winget search --id $($Prg.id) --exact)
        $WingetDetails = '(' + $($WingetDetails -join '|') + ')'
        $pos = $WingetDetails.IndexOf("-|")
        $WingetDescriptionPlus = $WingetDetails.Substring($pos+2)
        $pos = $WingetDescriptionPlus.IndexOf(" $($Prg.id)")
        $Prg.name = $WingetDescriptionPlus.Substring(0, $pos)
    }

    # check appliaction description and set if not present
    if(!$Prg.Description){
        $Prg.Description = "Installation via Windows Package Manager"
    }

    # check if for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        $Prg_img = "$RepoPath\template\winget\winget-managed.png"
    }

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Create-ChocoWin32App($Prg){
    Write-Host "Create win32 package for $($Prg.id) (Package Manager: Chocolatey)" -Foregroundcolor cyan

    # Set and create program folder
    $Prg_Path = "$Repo_choco\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content ".\template\choco\install.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1"

    # create param file
    if($Prg.parameter){New-Item -Path "$Prg_Path\parameter.txt" -ItemType "file" -Force -Value $Prg.parameter}

    # create uninstall file
    $(Get-Content ".\template\choco\uninstall.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"

    # create validation file
    $(Get-Content ".\template\choco\check.ps1").replace("CHOCOPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1"

    # check appliaction name and set if not present
    if(!$Prg.name){
        $ChocoDetails = '(' + $((choco search $Prg.id --by-id-only --exact -v) -join '|') + ')'
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

    # check for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        $Prg_img = "$RepoPath\template\choco\choco-managed.png"
    }

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Create-CustomWin32App($Prg){
    Write-Host "Creat win32 package for $($Prg.name) (custom, no Package Manager)" -Foregroundcolor cyan

    # Set program folder
    $Prg_Path = "$Repo_custom\$($Prg.name)"

    # check appliaction name and set if not present
    if(!$Prg.name){
        $Prg.name = $Prg.id
    }

    # check for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Repo_custom\$($Prg.id).png"
    }else{
        $Prg_img = "$RepoPath\template\custom\custom-managed.png"
    }

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Compile-Win32_intunewin($Prg, $Prg_Path, $Prg_img) {
    # download newest IntuneWinAppUtil
    Invoke-WebRequest -Uri $IntuneWinAppUtil_online -OutFile "$RepoPath\IntuneWinAppUtil.exe" -UseBasicParsing
    # create intunewin file
    Start-Process "$RepoPath\IntuneWinAppUtil.exe" -Argument "-c $Prg_Path -s install.ps1 -o $Prg_Path -q" -Wait -NoNewWindow

    # Upload app
    Upload-Win32App $Prg
}

function Upload-Win32App ($Prg){
    Write-Host "Uploading: $($Prg.name)" -Foregroundcolor cyan
}

$Prg_selection = Read-AppRepo | Out-GridView -OutputMode Multiple -Title "Select Applications to create and upload"

foreach($Prg in $Prg_selection){
    if($Prg.manager -eq "choco"){Create-ChocoWin32App $Prg}
    elseif($Prg.manager -eq "winget"){Create-WingetWin32App $Prg}
    else{Create-CustomWin32App $Prg}
}