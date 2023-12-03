function Add-IWDwinget4Dependency {
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER xxx
        xxxx

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [string]$WingetPackage_url = "https://github.com/FlorianSLZ/scloud/raw/main/Program%20-%20win32/Windows%20Package%20Manager/Windows%20Package%20Manager.zip",

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = $Global:GlobalRepoPath,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$WingetPackageName = "Windows Package Manager"

    )

    try{

        if($($global:intunewinOnly) -ne $true){
            Invoke-IWDLoginRequest

            $AppOnline = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $WingetPackageName} 

            if(!$AppOnline){
                Write-Host "Processing $WingetPackageName as prerequirement"

                $WingetWin32 = Get-IWDLocalApp -displayName $WingetPackageName -Meta
                if(!$WingetWin32){

                    Write-Warning "$WingetPackageName not found in local repository. `n I will download it for you ;)"
                    $ZIP_file = "$env:temp\$WingetPackageName.zip"
                    Invoke-WebRequest -Uri $WingetPackage_url -OutFile $ZIP_file

                    $ExtractPath = "$RepoPath\$WingetPackageName"
                    Expand-Archive $ZIP_file -DestinationPath $ExtractPath
                    Remove-Item $ZIP_file -Force

                    $WingetWin32 = Get-IWDLocalApp -displayName $WingetPackageName -Meta

                }

                Publish-IWDWin32App -AppInfo $WingetWin32
            }
        }

    }catch{
        Write-Error "Error adding $WingetPackageName `n$_"
    }
}
