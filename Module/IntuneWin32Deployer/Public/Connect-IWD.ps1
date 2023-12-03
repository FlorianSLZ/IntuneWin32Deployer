function Connect-IWD {

    <#
    .SYNOPSIS
        Connect to Microsoft Graph API.

    .DESCRIPTION
        Connect to Microsoft Graph API using either Azure App authentication or user authentication.

    .PARAMETER ClientId
        The Azure App ID (Client ID) for connecting to Microsoft Graph.

    .PARAMETER ClientSecret
        The App Secret for connecting to Microsoft Graph when using Azure App authentication.

    .PARAMETER TenantId
        The Tenant ID for connecting to Microsoft Graph when using Azure App authentication.

    .EXAMPLE
        Example 1:
        Connect-IWD -ClientId "YourAppId" -ClientSecret "YourAppSecret" -TenantId "YourTenantId"

        This command connects to Microsoft Graph using Azure App authentication with the specified Client ID, Client Secret, and Tenant ID.

    .EXAMPLE
        Example 2:
        Connect-IWD

        This command connects to Microsoft Graph using user authentication.

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-10-15

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "AppId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [parameter(Mandatory = $false, HelpMessage = "TenantId for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,

        [parameter(Mandatory = $false, HelpMessage = "App Secret for connection with MSGraph")]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret
    )

    if($ClientId -and $ClientSecret -and $TenantId){
        Write-Verbose "Graph connection via Azure App, Tenant: $TenantId"
        $authority = "https://login.windows.net/$TenantId"
        Update-MSGraphEnvironment -AppId $ClientId -Quiet
        Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $ClientSecret -Quiet

    }else{
        # Disconnect old session
        if($(Get-MgContext).AppName){   
            Write-Host "Kill old Graph Session"
            Disconnect-Graph    
        }

        Write-Verbose "Graph connection via user authentification"
        $MSGraph = Connect-MgGraph # -Scopes "User.Read.All","Group.ReadWrite.All"
        Write-Verbose $MSGraph

        $global:orgInfo = Invoke-MgGraphRequest -URI "https://graph.microsoft.com/v1.0/organization"
        $MSIntuneGraph = Connect-MSIntuneGraph -TenantID $orgInfo.Value.id
        Write-Verbose $MSIntuneGraph

    } 
    
}