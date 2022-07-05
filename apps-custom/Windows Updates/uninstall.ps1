$PackageName = "Windows-Updates"

$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\uninstall\$PackageName-uninstall.log" -Force

Remove-Item -Path "$Path_4netIntune\Validation\$PackageName" -Force

Stop-Transcript