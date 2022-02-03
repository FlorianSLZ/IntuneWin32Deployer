Param
  (
    [parameter(Mandatory=$false)]
    [String[]]
    $param
  )
  
$ProgramName = "WINGETPROGRAMID"
$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\$ProgramName-install.log" -Force

winget install --exact --silent $ProgramName --log "$Path_4netIntune\Log\$ProgramName.log" --accept-package-agreements --accept-source-agreements $param

Stop-Transcript
