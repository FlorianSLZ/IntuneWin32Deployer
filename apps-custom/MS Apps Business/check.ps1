$ProgramName = "PROGRAMNAME"
$ProgramPath = "C:\Program Files\PRPOGRAM\start.exe"
#Check if Office 365 suite was installed correctly.
$RegLocations = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$OfficeInstalled = $False
foreach ($Key in (Get-ChildItem $RegLocations) ) {
  if ($Key.GetValue('DisplayName') -like '*Microsoft 365*') {
    $OfficeVersionInstalled = $Key.GetValue('DisplayName')
    $OfficeInstalled = $True
  }
}

if ($OfficeInstalled) {
  Write-Verbose "$($OfficeVersionInstalled) installed successfully!"
Write-Host "Found it!"
exit 0
}
else {
  Write-Warning 'Microsoft 365 was not detected.'
exit 1
}
