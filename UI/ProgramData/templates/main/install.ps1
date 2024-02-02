$AppInfo = Get-Content -Raw -Path "$PSScriptRoot\AppInfo.json" | ConvertFrom-Json
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$($AppInfo.Name)-install.log" -Force

try{

#####################################
# START Installation

## THE INSTALLATION  ##

# END Installation
#####################################

}
catch{
    $_
}

Stop-Transcript
