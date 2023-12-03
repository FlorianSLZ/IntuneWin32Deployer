function Get-IWDSettings {

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

    param ()

    if (Test-Path $global:GlobalSettingsFilePath) {
        $settings = Get-Content -Path $global:GlobalSettingsFilePath | ConvertFrom-Json

        $global:GlobalRepoPath = $settings.RepoPath
        $global:GlobalAzureADGroup = $settings.AzureADGroup
        $global:GlobalwingetTemplate = $settings.wingetTemplate
        $global:GlobalchocoTemplate = $settings.chocoTemplate
        
    }else{
        Write-Warning "No settings file found. Please run Set-IWDSettings first."
    }
}