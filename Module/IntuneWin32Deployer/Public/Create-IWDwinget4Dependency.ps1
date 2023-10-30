function Add-IWDwinget4Dependency {
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER PropertyName1
        xxxx

    .PARAMETER PropertyName2
        xxx

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [array]$intunewinOnly

    )

    try{
        if($($global:intunewinOnly) -ne $true){
            $Session = Connect-MSIntuneGraph -TenantID $SettingsVAR.Tenant
            Write-Verbose $Session

            $App = @()
            $App += New-Object psobject -Property @{Name = "Windows Package Manager";id = "winget"; Description = "Windows Package Manager is a comprehensive package manager solution that consists of a command line tool and set of services for installing applications on Windows 10 and Windows 11.";manager = "";install = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\install.ps1";uninstall = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1";as = "system";publisher = "";parameter = ""}

            $AppOnline = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $App.Name} | Select-Object name, id
            if(!$AppOnline){
                Write-Host "Processing Windows Package Manager as prerequirement"
                Add-IWDWin32App $App -Type "custom"
            }
        }
    }catch{
        Write-Host "Error adding dependency for $($App.Name)" -ForegroundColor Red
        $_
    }

}
