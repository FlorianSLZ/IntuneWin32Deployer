function Set-IWDAppInfo{
    
    <#
    .SYNOPSIS
        Adds applications to a repository and, if desired, creates IntuneWin packages.

    .DESCRIPTION
        This function allows you to add applications to a repository, either using Chocolatey or Winget as the package manager. 
        It provides an interactive selection process for adding applications and optionally creating IntuneWin packages.

    .PARAMETER AppPackage
        An array of application to add.

    .PARAMETER type
        Specifies the package manager to use, either "choco" for Chocolatey or "winget" for Winget.

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-09-12

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "An array of application to add.")]
        [ValidateNotNullOrEmpty()]
        [array]$AppPackage,

        [parameter(Mandatory = $true, HelpMessage = "Specifies the package manager to use, either 'choco' for Chocolatey or 'winget' for Winget.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("choco", "winget")]
        [string]$Type,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer"
    )
    
    try{

        $AppInfo_file = "$RepoPath\$($AppPackage.displayName)\AppInfo.json"
        $AppInfo = Get-Content $AppInfo_file -Raw | ConvertFrom-Json

        switch ($Type) {
            "choco"  {

                $AppInfo.displayName    = $AppPackage.displayName
                $AppInfo.Version        = $AppPackage.Version
                $AppInfo.Platform       = $AppPackage.Platform
                $AppInfo.Channel        = $AppPackage.Channel
                $AppInfo.Ring           = $AppPackage.Ring
                $AppInfo.Release        = $AppPackage.Release
                $AppInfo.Architecture   = $AppPackage.Architecture
                $AppInfo.Type           = $AppPackage.Type
                $AppInfo.Language       = $AppPackage.Language
            

            }
            "winget"{

            }
            default {Write-Error "Something went wrong. Unsuported type."; break}
        }

        $AppInfo | ConvertTo-Json | Out-File $AppInfo_file -Force 




        
    }catch{
        Write-Error "Error while processing $($AppInfo.displayName) `n$_"
    }

}
