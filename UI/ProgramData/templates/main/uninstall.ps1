$AppInfo = Get-Content -Raw -Path "$($SelectedFolder.FullName)\AppInfo.json" | ConvertFrom-Json
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$($AppInfo.Name)-uninstall.log" -Force

try{

#####################################
# START Installation

## THE UNINSTALLATION  ##

# END Installation
#####################################

}
catch{
    $_
}

Stop-Transcript
