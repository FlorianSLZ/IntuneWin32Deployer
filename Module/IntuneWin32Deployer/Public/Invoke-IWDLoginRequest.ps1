function Invoke-IWDLoginRequest {

    <#
    .SYNOPSIS
        Invoke Login Check and Token refresh

    .DESCRIPTION
        Invoke Login Check and Token refresh

    #>

    param ()

        # Check Session / MS Graph Connection
        if(!$(Get-MgContext).AppName){   Connect-IWD    }
        else{
            # Refresh Token
            Connect-MSIntuneGraph -TenantID $Global:AccessTokenTenantID -Refresh | Out-Null
        }  
}