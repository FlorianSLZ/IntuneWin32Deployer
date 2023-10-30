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


    try{
        if($($global:intunewinOnly) -ne $true){
            $Session = Connect-MSIntuneGraph -TenantID $SettingsVAR.Tenant
            Write-Verbose $Session
            
            $App = @()
            $App += New-Object psobject -Property @{Name = "Chocolatey";id = "Chocolatey"; Description = "Paketmanager";manager = "";install = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -command .\install.ps1";uninstall = "no uninstall!";as = "system";publisher = "";parameter = ""}

            $AppChocolatey = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $App.Name} | Select-Object displayName, id
            if(!$AppChocolatey){
                Write-Host "Processing Chocolatey as prerequirement"
                Add-IWDWin32App $App -Type "custom"
            }
        }
    }catch{
        Write-Host "Error adding dependency for $($App.Name)" -ForegroundColor Red
        $_
    }

}
