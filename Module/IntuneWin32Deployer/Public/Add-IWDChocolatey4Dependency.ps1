function Add-IWDChocolatey4Dependency{
    
    <#
    .SYNOPSIS
        Add Chocolatey as a dependency for application deployment.

    .DESCRIPTION
        This function adds Chocolatey as a prerequisite dependency for application deployment in Microsoft Intune.

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-10-15

    #>
    

    param (
        [parameter(Mandatory = $false, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [string]$ChocolateyPackage_url = "https://github.com/FlorianSLZ/scloud/raw/main/chocolatey/chocolatey/chocolatey.zip",

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = $Global:GlobalRepoPath,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$ChocoPackageName = "Chocolatey"

    )

try{

    if($($global:intunewinOnly) -ne $true){
        Invoke-IWDLoginRequest

        $AppOnline = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $ChocoPackageName} 

        if(!$AppOnline){
            Write-Host "Processing $ChocoPackageName as prerequirement"

            $ChocoWin32 = Get-IWDLocalApp -displayName $ChocoPackageName -Meta
            if(!$ChocoWin32){

                Write-Warning "$ChocoPackageName not found in local repository. `n I will download it for you ;)"
                $ZIP_file = "$env:temp\$ChocoPackageName.zip"
                Invoke-WebRequest -Uri $ChocoPackage_url -OutFile $ZIP_file

                $ExtractPath = "$RepoPath\$ChocoPackageName"
                Expand-Archive $ZIP_file -DestinationPath $ExtractPath
                Remove-Item $ZIP_file -Force

                $ChocoWin32 = Get-IWDLocalApp -displayName $ChocoPackageName -Meta

            }

            Publish-IWDWin32App -AppInfo $ChocoWin32
        }
    }

}catch{
    Write-Error "Error adding $ChocoPackageName `n$_"
}
}
