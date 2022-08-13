#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - Module/Function
#   Author:     Florian Salzmann
#   Website:    http://www.scloud.work
#   Twitter:    https://twitter.com/FlorianSLZ
#   LinkedIn:   https://www.linkedin.com/in/fsalzmann/
#
#############################################################################################################

# Requires -Modules IntuneWin32App, AzureAD 
# Install-Module NuGet, MSAL.PS, IntuneWin32App, AzureAD  -Scope CurrentUser -Force

<# temporarry fix for IntuneWin32App module
$oldLine = '$ScriptContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.IO.File]::ReadAllBytes("$($ScriptFile)") -join [Environment]::NewLine))'
$newLine = '$ScriptContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$($ScriptFile)"))'
$File = "$([Environment]::GetFolderPath("MyDocuments"))\WindowsPowerShell\Modules\IntuneWin32App\1.3.3\Public\New-IntuneWin32AppDetectionRuleScript.ps1"
(Get-Content $File).Replace($oldLine,$newLine) | Set-Content $File

#>


<#
    .SYNOPSIS
    Packages choco, winget and custom apps for MEM (Intune) deployment.
    Uploads the packaged into the target Intune tenant.

    .NOTES
    For details on IntuneWin32App go here: https://scloud.work/Intune-Win32-Deployer
    
    .PARAMETER Path
    Path to use for downloading and processing packages

    .PARAMETER PackageOutputPath
    Path to export the created packages

    .PARAMETER TenantName
    Microsoft Endpoint Manager (Intune) Azure Active Directory Tenant. 
    Prefix from yout onmicrosfot.com Domain.
    Ex. scloudwork.onmicrosoft.com --> scloudwork

    .EXAMPLE
    .\Intune-Win32-Deployer.ps1 -TenantName scloudwork.onmicrosoft.com -Publisher scloud
    
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $Repo_Path = "$PSScriptRoot",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_choco = "$Repo_Path\apps-choco",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_winget = "$Repo_Path\apps-winget",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_custom = "$Repo_Path\apps-custom",

    [Parameter(Mandatory = $False)]
    [System.String] $Repo_CSV_Path = "$Repo_Path\Applications.csv",

    [Parameter(Mandatory = $true)]
    [System.String] $TenantName,

    [Parameter(Mandatory = $False)]
    [bool] $intunewinOnly = $false,

    [Parameter(Mandatory = $true)]
    [System.String] $Publisher = "scloud",

    [Parameter(Mandatory = $False)]
    [System.String] $IntuneWinAppUtil_online = "https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe",  

    [switch]$Force
    
)

function Read-AppRepo{
    $AppRepo = Import-CSV -Path $Repo_CSV_Path -Encoding UTF8 -Delimiter ";"
    return $AppRepo  

}

function Add-AppRepo ($App2Add){
    $AppRepo = Read-AppRepo
    $AppRepo += $App2Add
    $AppRepo | Export-CSV -Path $Repo_CSV_Path -NoTypeInformation -Encoding UTF8 -Delimiter ";"
}

function SearchAdd-ChocoApp ($searchText) {
    $Chocos2add = choco search $searchText | Out-GridView -OutputMode Multiple -Title "Select Applications to add"
    foreach($ChocoApp in $Chocos2add){
        # parameter mapping
        $ChocoApp_ID = $($ChocoApp.split(' ')[0])
        $ChocoApp_new = New-Object PsObject -Property @{ id = "$ChocoApp_ID"; manager = "choco" }
        # add to CSV
        Add-AppRepo $ChocoApp_new
        # xy added, wanna deploy?
        $deployYN = New-Object -ComObject Wscript.Shell
        if($($deployYN.Popup("Chocolatey App >$ChocoApp_ID< added. Do you want to create the intunewin?",0,"Alert",64+4)) -eq 6){
            # Trigger creation process
            $Prg = Read-AppRepo | Where-Object {$_.id -eq "$ChocoApp_ID"} | Select-Object -first 1
            Create-ChocoWin32App $Prg
        }


    }

}

function SearchAdd-WinGetApp ($searchText) {

    $winget2add = winget search --id $searchText --exact --accept-source-agreements
    if($winget2add -like "*$searchText*"){
        # parameter mapping
        $WingetApp_new = New-Object PsObject -Property @{ id = "$searchText"; manager = "choco" }
        # add to CSV
        Add-AppRepo $WingetApp_new
        # xy added, wanna deploy?
        $deployYN = New-Object -ComObject Wscript.Shell
        if($($deployYN.Popup("Winget App >$searchText< added. Do you want to create the intunewin?",0,"Alert",64+4)) -eq 6){
            # Trigger creation process
            $Prg = Read-AppRepo | Where-Object {$_.id -eq "$searchText"} | Select-Object -first 1
            Create-winget4Dependency
            Create-WingetWin32App $Prg
        }
    }else{
        Write-Error "ID not found!"
    }

}

function Create-WingetWin32App($Prg){
    Write-Host "Creat win32 package for $($Prg.id) (Microsoft Package Manager)" -Foregroundcolor cyan

    # Set and create program folder
    $Prg_Path = "$Repo_winget\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force

    # create install file
    $(Get-Content "$Repo_Path\ressources\template\winget\install.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1" -Encoding utf8

    # create uninstall file
    $(Get-Content "$Repo_Path\ressources\template\winget\uninstall.ps1").replace("WINGETPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1" -Encoding utf8

    # create validation file
    $(Get-Content "$Repo_Path\ressources\template\winget\check.ps1").replace("WINGETPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1" -Encoding utf8

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
    if(!$Prg.as){$Prg.as = "system"}

    # check if for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        $Prg_img = "$Repo_Path\ressources\template\winget\winget-managed.png"
    }

    # Set Dependency if not defined
    if(!$Prg.dependency){$Prg.dependency = "Windows Package Manager"}

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Create-ChocoWin32App($Prg){
    Write-Host "Create win32 package for $($Prg.id) (Package Manager: Chocolatey)" -Foregroundcolor cyan

    # Set and create program folder
    $Prg_Path = "$Repo_choco\$($Prg.id)"
    New-Item $Prg_Path -type Directory -Force | Out-Null

    # create install file
    $(Get-Content "$Repo_Path\ressources\template\choco\install.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\install.ps1" -Encoding utf8

    # create param file
    if($Prg.parameter){New-Item -Path "$Prg_Path\parameter.txt" -ItemType "file" -Force -Value $Prg.parameter}

    # create uninstall file
    $(Get-Content "$Repo_Path\ressources\template\choco\uninstall.ps1").replace("CHOCOPROGRAMID","$($Prg.id)") | Out-File "$Prg_Path\uninstall.ps1"  -Encoding utf8

    # create validation file
    $(Get-Content "$Repo_Path\ressources\template\choco\check.ps1").replace("CHOCOPROGRAMID","$($Prg.id)")  | Out-File "$Prg_Path\check.ps1" -Encoding utf8

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
        $ChocoDetails = '(' + $((choco search $Prg.id --by-id-only --exact -v) -join '|') + ')'
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
        $Prg_img = "$Repo_Path\ressources\template\choco\choco-managed.png"
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


function Create-winget4Dependency {
    try{
        $Session = Connect-MSIntuneGraph -TenantID $TenantName

        $App = @()
        $App += New-Object psobject -Property @{Name = "Windows Package Manager";id = "winget"; Description = "Windows Package Manager is a comprehensive package manager solution that consists of a command line tool and set of services for installing applications on Windows 10 and Windows 11.";manager = "";install = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\install.ps1";uninstall = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1";as = "system";publisher = "";parameter = ""}

        $AppOnline = Get-IntuneWin32App | where {$_.DisplayName -eq $App.Name} | select name, id
        if(!$AppOnline){
            Write-Host "Processing Windows Package Manager as prerequirement"
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
    if (!$CheckChocolatey){
        Write-Host "Instaling Chocolatey (on local machine)"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }

}

function Create-CustomWin32App($Prg){
    Write-Host "Creat win32 package for $($Prg.name) (custom, no Package Manager)" -Foregroundcolor cyan

    # check appliaction name and set if not present
    if(!$Prg.name){
        $Prg.name = $Prg.id
    }

    # Set program folder
    $Prg_Path = "$Repo_custom\$($Prg.name)"

    # check for img
    if(Get-ChildItem $Prg_Path -Filter "$($Prg.id).png"){
        $Prg_img = "$Prg_Path\$($Prg.id).png"
    }else{
        if(Get-ChildItem $Prg_Path -Filter "$($Prg.name).png"){
            $Prg_img = "$Prg_Path\$($Prg.name).png"
        }else{
            $Prg_img = "$Repo_Path\ressources\template\custom\program.png"
        }
    }

    # Create intunewin
    Compile-Win32_intunewin $Prg $Prg_Path $Prg_img
}

function Compile-Win32_intunewin($Prg, $Prg_Path, $Prg_img) {
    # download newest IntuneWinAppUtil
    Invoke-WebRequest -Uri $IntuneWinAppUtil_online -OutFile "$Repo_Path\ressources\IntuneWinAppUtil.exe" -UseBasicParsing
    # create intunewin file
    Start-Process "$Repo_Path\ressources\IntuneWinAppUtil.exe" -Argument "-c $Prg_Path -s install.ps1 -o $Prg_Path -q" -Wait -NoNewWindow

    if($intunewinOnly -eq $false){
        # Upload app
        Upload-Win32App $Prg $Prg_Path $Prg_img
    }else{
        # Open file location / intunewin 
        Invoke-Item $Prg_Path
    }
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
        $Icon = New-IntuneWin32AppIcon -FilePath $Prg_img

        # Install/uninstall commands
        $InstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\install.ps1"
        $UninstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1"
        
        # Upload 
        $upload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $DisplayName -Description $($Prg.description) -Publisher $Publisher -InstallExperience $($Prg.as) -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon        

        Write-Host "Upload completed: $($Prg.name)" -Foregroundcolor cyan
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
            $Session = Connect-MSIntuneGraph -TenantID $TenantName
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

function Import-FromCatalog{
    $Prg_selection = Read-AppRepo | Out-GridView -OutputMode Multiple -Title "Select Applications to create and upload"
    if($Prg_selection.manager -like "*choco*"){CheckInstall-LocalChocolatey}
    if($Prg_selection.manager -like "*choco*"){Create-Chocolatey4Dependency}
    if($Prg_selection.manager -like "*winget*"){Create-winget4Dependency}

    foreach($Prg in $Prg_selection){
        if($Prg.manager -eq "choco"){Create-ChocoWin32App $Prg}
        elseif($Prg.manager -eq "winget"){Create-WingetWin32App $Prg}
        else{Create-CustomWin32App $Prg}
    }
}
