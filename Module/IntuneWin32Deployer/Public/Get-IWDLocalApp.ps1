function Get-IWDLocalApp()
{
    <#
    .SYNOPSIS
        Get local Evergreen Apps

    .DESCRIPTION
        Get local Evergreen Apps
        
    .PARAMETER Multiple
        Allows to select multiple Apps instead of one. 


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Allows to select multiple Apps instead of one.")]
        [ValidateNotNullOrEmpty()]
        [switch]$Multiple, 

        [parameter(Mandatory = $false, HelpMessage = "Get all local present Apps. ")]
        [ValidateNotNullOrEmpty()]
        [switch]$All, 

        [parameter(Mandatory = $false, HelpMessage = "Get local Apps Metadate (AppInfo.json)")]
        [ValidateNotNullOrEmpty()]
        [switch]$Meta, 

        [parameter(Mandatory = $false, HelpMessage = "Get local App folder by displayName in JSON file (AppInfo.json")]
        [ValidateNotNullOrEmpty()]
        [switch]$Folder, 

        [parameter(Mandatory = $false, HelpMessage = "Local Name of the App/Folder")]
        [ValidateNotNullOrEmpty()]
        [string]$displayName,

        [parameter(Mandatory = $false, HelpMessage = "Specifies the package manager to use, either 'choco' for Chocolatey or 'winget' for Winget.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("choco", "winget", "custom")]
        [string]$Type,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = $Global:GlobalRepoPath

    )

    if($Folder){
        # Search for AppInfo.json files and filter based on displayName
        $SelectedAppFolders = Get-ChildItem -Path $RepoPath -Recurse -Filter "AppInfo.json" | ForEach-Object {
            $jsonContent = Get-Content $_.FullName | ConvertFrom-Json
            if ($jsonContent.displayName -eq $displayName) {
                $_.Directory.FullName
            }
        }

        if ($SelectedAppFolders.Count -eq 0) {
            Write-Warning "No App with displayName '$displayName' found."
        }
    }
    elseif($All)
    {
        $SelectedAppFolders = Get-ChildItem $RepoPath -Directory 
    }
    elseif($Multiple)
    {
        $SelectedAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Multiple
    }
    elseif($Type){

        # Recursively search for JSON files containing the Type "$Type"
        $SelectedAppFolders = Get-ChildItem -Path $RepoPath -Filter "AppInfo.json" -File -Recurse | ForEach-Object {
            $jsonContent = Get-Content $_.FullName | ConvertFrom-Json
            if ($jsonContent.Type -eq "$Type") {
                $(Get-Item $_.FullName.Replace("\AppInfo.json",""))
            }
        }
    }
    elseif($displayName)
    {
        # Recursively search for JSON files containing the displayName "$displayName"
        $SelectedAppFolders = Get-ChildItem -Path $RepoPath -Filter "AppInfo.json" -File -Recurse | ForEach-Object {
            $jsonContent = Get-Content $_.FullName | ConvertFrom-Json
            if ($jsonContent.displayName -eq "$displayName") {
                $(Get-Item $_.FullName.Replace("\AppInfo.json",""))
            }
        }
    }
    else
    {
        $SelectedAppFolders = Get-ChildItem $RepoPath -Directory | Out-GridView -OutputMode Single
    }

    if($Meta)
    {
        $AppInfo = @()
        foreach($SelectedFolder in $SelectedAppFolders){
            if(Test-Path -Path "$($SelectedFolder.FullName)\AppInfo.json"){
                $AppInfo += Get-Content -Raw -Path "$($SelectedFolder.FullName)\AppInfo.json" | ConvertFrom-Json
            }
        }
        
        return $AppInfo
    }
    else {
        return $SelectedAppFolders
    }
}
