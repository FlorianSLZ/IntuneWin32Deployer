$AppInfo = Get-Content -Raw -Path "$($SelectedFolder.FullName)\AppInfo.json" | ConvertFrom-Json
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$($AppInfo.Name)-install.log" -Force

try{

#####################################
# START Installation

# Check choco.exe 
$localprograms = C:\ProgramData\chocolatey\choco.exe list
if ($localprograms -like "*Chocolatey*"){
    Write-Host "Chocolatey installed"
}else{
    Write-Host "Chocolatey not Found!"
    break
}

# Scheduled Task for "choco upgrade -y"
$schtaskName = $($AppInfo.Name)
$schtaskDescription = "Upgade der mit Chocolaty verwalteten Paketen. V$($Version)"
$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Wednesday -At 8pm
$principal= New-ScheduledTaskPrincipal -UserId 'SYSTEM'
$action = New-ScheduledTaskAction –Execute "C:\ProgramData\chocolatey\choco.exe" -Argument 'upgrade all -y'
$settings= New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $schtaskName -Trigger $trigger1,$trigger2 -Action $action -Principal $principal -Settings $settings -Description $schtaskDescription -Force

## Detection Key
$Path = $($AppInfo.detection.Registry.Key) 
$Key = $($AppInfo.detection.Registry.Name)
$KeyFormat = $($AppInfo.detection.Registry.Type)
$Value = $($AppInfo.detection.Registry.Value)

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}

# END Installation
#####################################

}
catch{
    $_
}

Stop-Transcript
