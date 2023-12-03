function Set-IWDSettings {

    <#
    .SYNOPSIS
        Connect to Microsoft Graph API.

    .DESCRIPTION
        Connect to Microsoft Graph API using either Azure App authentication or user authentication.

    .PARAMETER xxx

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-10-15

    #>

    param (
        [string]$RepoPath,
        [bool]$AzureADGroup,
        [string]$wingetTemplate,
        [string]$chocoTemplate
    )

    if($RepoPath){
        $global:GlobalRepoPath = $RepoPath
    }else{
        $global:GlobalRepoPath = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer"
    }

    if($AzureADGroup){
        $global:GlobalAzureADGroup = $AzureADGroup
    }else{
        $global:GlobalAzureADGroup = $false
    }

    if($wingetTemplate){
        $global:GlobalwingetTemplate = $wingetTemplate
    }else{
        $global:GlobalwingetTemplate = "https://raw.githubusercontent.com/FlorianSLZ/scloud/main/templates/winget.json"
    }

    if($chocoTemplate){
        $global:GlobalchocoTemplate = $chocoTemplate
    }else{
        $global:GlobalchocoTemplate = "https://raw.githubusercontent.com/FlorianSLZ/scloud/main/templates/choco.json"
    }

    $settings = @{
        RepoPath = $global:GlobalRepoPath
        AzureADGroup = $global:GlobalAzureADGroup
        wingetTemplate = $global:GlobalwingetTemplate
        chocoTemplate = $global:GlobalchocoTemplate
    }

    $settings | ConvertTo-Json | Set-Content -Path $global:GlobalSettingsFilePath -Force
}