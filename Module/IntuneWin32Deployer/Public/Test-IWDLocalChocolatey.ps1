function Test-IWDLocalChocolatey{
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER PropertyName1
        URL for the choco installer download
        Found at: https://chocolatey.org/install

    #>

    param (

        [parameter(Mandatory = $false, HelpMessage = "URL for the choco installer download")]
        [ValidateNotNullOrEmpty()]
        [string]$ChocoURL = "https://community.chocolatey.org/install.ps1"

    )
    try{

        # Check if chocolatey is installed
        $CheckChocolatey = C:\ProgramData\chocolatey\choco.exe list 
        if (!$CheckChocolatey){
            Write-Host "Installing Chocolatey (on local machine)"
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("$ChocoURL"))
        }
        
        
    }catch{
        Write-Error "Error while processing $PropertyName1 `n$_"
    }

}
