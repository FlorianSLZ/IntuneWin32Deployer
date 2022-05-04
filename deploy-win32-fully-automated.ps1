<#Requires -Modules IntuneWin32App, MSAL.PS, AzureAD  
#Install-Module IntuneWin32App, MSAL.PSAuth, AzureAD  -Scope CurrentUser -Force
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
    .\deploy-win32-fully-automated.ps1 -TenantName scloudwork.onmicrosoft.com -Publisher scloud
    
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Repo_Path = "$PSScriptRoot",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_choco = "$PSScriptRoot\apps-choco",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_winget = "$PSScriptRoot\apps-winget",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_custom = "$PSScriptRoot\apps-custom",

    [Parameter(Mandatory = $true)]
    [System.String] $TenantName,

    [Parameter(Mandatory = $true)]
    [System.String] $Publisher = "scloud",

    [Parameter(Mandatory = $False)]
    [System.String] $IntuneWinAppUtil_online = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe",  

    [switch]$Force
    
)

function Read-AppRepo{
    $AppRepo = Import-CSV -Path "$Repo_Path\Applications.csv" -delimiter ";"
    return $AppRepo  

}

function Create-WingetWin32App($Prg){
    Write-Host "Creat win32 package for $($Prg.id) (Microsoft Package Manager)" -Foregroundcolor cyan

    # Set and create program folder
    $Prg_Path = "$Repo_winget\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content "$Repo_Path\template\winget\install.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1" -Encoding ascii

    # create uninstall file
    $(Get-Content "$Repo_Path\template\winget\uninstall.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1" -Encoding ascii

    # create validation file
    $(Get-Content "$Repo_Path\template\winget\check.ps1").replace("WINGETPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1" -Encoding ascii

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

    # check appliaction InstallExperience and set if not present
    if(!$Prg.as){$Prg.as = "user"}

    # check if for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        $Prg_img = "$Repo_Path\template\winget\winget-managed.png"
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
    $(Get-Content ".\template\choco\install.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1" -Encoding ascii

    # create param file
    if($Prg.parameter){New-Item -Path "$Prg_Path\parameter.txt" -ItemType "file" -Force -Value $Prg.parameter}

    # create uninstall file
    $(Get-Content ".\template\choco\uninstall.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"  -Encoding ascii

    # create validation file
    $(Get-Content ".\template\choco\check.ps1").replace("CHOCOPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1" -Encoding ascii

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

    # check appliaction InstallExperience and set if not present
    if(!$Prg.as){$Prg.as = "system"}

    # check for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        $Prg_img = "$Repo_Path\template\choco\choco-managed.png"
    }

    # Set Dependency if not defined
    if(!$Prg.dependency){$Prg.dependency = "Chocolatey"}

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Create-Chocolatey4Dependency {
    try{
        $Session = Connect-MSIntuneGraph -TenantID $TenantName

        $App = @()
        $App += New-Object psobject -Property @{Name = "Chocolatey";id = "Chocolatey"; Description = "Paketmanager";manager = "";install = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\install.ps1";uninstall = "no uninstall!";as = "system";publisher = "";parameter = ""}

        $AppChocolatey = Get-IntuneWin32App | where {$_.DisplayName -eq $App.Name} | select name, id
        if(!$AppChocolatey){
            Write-Host "Processing Chocolatey as prerequirement"
            Create-CustomWin32App $App
        }
    }catch{
        Write-Host "Error adding dependency for $($App.Name)" -ForegroundColor Red
        $_
    }

}

function CheckInstall-LocalChocolatey{
    # Check if chocolatey is installed
    $CheckChocolatey = C:\ProgramData\chocolatey\choco.exe list --localonly
    if ($CheckChocolatey){
        Write-Host "Chocolatey aleaready installed" -Foregroundcolor green
    }else{
        Write-Host "Instaling Chocolatey"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }

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
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        if(Get-ChildItem $Prg_Path -Filter "$($Prg.name).png"){
            $Prg_img = "$Prg_Path\$($Prg.name).png"
        }else{
            $Prg_img = "$Repo_Path\template\custom\program.png"
        }
    }

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Compile-Win32_intunewin($Prg, $Prg_Path, $Prg_img) {
    # download newest IntuneWinAppUtil
    Invoke-WebRequest -Uri $IntuneWinAppUtil_online -OutFile "$Repo_Path\IntuneWinAppUtil.exe" -UseBasicParsing
    # create intunewin file
    Start-Process "$Repo_Path\IntuneWinAppUtil.exe" -Argument "-c $Prg_Path -s install.ps1 -o $Prg_Path -q" -Wait -NoNewWindow

    # Upload app
    Upload-Win32App $Prg $Prg_Path $Prg_img
}

function Upload-Win32App ($Prg, $Prg_Path, $Prg_img){
    Write-Host "Uploading: $($Prg.name)" -Foregroundcolor cyan

    try{
        
        # Graph Connect 
        $Session = Connect-MSIntuneGraph -TenantID $TenantName

        # get .intunewin for Upload 
        $IntuneWinFile = "$Prg_Path\install.intunewin"

        # read Displayname 
        $DisplayName = "$($Prg.Name)"

        # create detection rule
        $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile "$Prg_Path\check.ps1" -EnforceSignatureCheck $false -RunAs32Bit $false

        # minimum requirements
        $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture x64 -MinimumSupportedOperatingSystem 2004

        # picture for win32 app (shown in company portal)
        $Prg_img
        $Icon = New-IntuneWin32AppIcon -FilePath $Prg_img

        # Install/uninstall commands
        $InstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\install.ps1"
        $UninstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1"
        
        # Upload 
        $upload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $($Prg.description) -Publisher $Publisher -InstallExperience $($Prg.as) -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon        

    }
    catch{
        Write-Host "Error application $($Prg.Name)" -ForegroundColor Red
        $_
    }
    # Sleep to prevent block from azure on a mass upload
    Start-sleep -s 15

    try{
        # Check dependency
        if($Prg.dependency){
            Write-Host "  Processing dependency $($Prg.dependency) to $($Prg.Name)" -ForegroundColor Cyan
            $UploadedApp = Get-IntuneWin32App | where {$_.DisplayName -eq $Prg.Name} | select name, id
            $DependendProgram = Get-IntuneWin32App | where {$_.DisplayName -eq $Prg.dependency} | select name, id
            if(!$DependendProgram){
                Write-Host "    dependent program $($Prg.dependency) is not present in the MEM enviroment, please create/upload first." -ForegroundColor Orange
            }
            $DependendProgram = Get-IntuneWin32App | where {$_.DisplayName -eq $Prg.dependency} | select name, id
            $Dependency = New-IntuneWin32AppDependency -id $DependendProgram.id -DependencyType AutoInstall
            $UploadProcess = Add-IntuneWin32AppDependency -id $UploadedApp.id -Dependency $Dependency
            Write-Host "  Added dependency $($Prg.dependency) to $($Prg.Name)" -ForegroundColor Cyan
        }
    }catch{
        Write-Host "Error adding dependency for $($Prg.Name)" -ForegroundColor Red
        $_
    }

}

$Prg_selection = Read-AppRepo | Out-GridView -OutputMode Multiple -Title "Select Applications to create and upload"
if($Prg_selection.manager -like "*choco*"){CheckInstall-LocalChocolatey}
if($Prg_selection.manager -like "*choco*"){Create-Chocolatey4Dependency}

foreach($Prg in $Prg_selection){
    if($Prg.manager -eq "choco"){Create-ChocoWin32App $Prg}
    elseif($Prg.manager -eq "winget"){Create-WingetWin32App $Prg}
    else{Create-CustomWin32App $Prg}
}