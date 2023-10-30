function Add-xxx{
    
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
        [array]$PropertyName1,

        [parameter(Mandatory = $true, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [string]$PropertyName2,

        [parameter(Mandatory = $false, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [switch]$PropertyName3

    )
    try{

        
        
    }catch{
        Write-Error "Error while processing $PropertyName1 `n$_"
    }

}
