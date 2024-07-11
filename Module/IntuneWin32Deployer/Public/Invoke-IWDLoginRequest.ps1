function Invoke-IWDLoginRequest {

    <#
    .SYNOPSIS
        Invoke Login Check and Token refresh

    .DESCRIPTION
        Invoke Login Check and Token refresh

    #>

    param ()

        # Check Session / MS Graph Connection
        $CurrentMgContext = Get-MgContext

        if(!$($CurrentMgContext.AppName)){   Connect-IWD    }
        else{
            # Refresh Token
            Connect-MSIntuneGraph -TenantID $CurrentMgContext.TenantId -ClientID $CurrentMgContext.ClientID -Refresh | Out-Null
        }  
}