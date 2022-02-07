$PackageName = "WindowsPackageManager"
$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\uninstall\$PackageName-uninstall.log" -Force

Remove-AppPackage -Package "Microsoft.DesktopAppInstaller"

Stop-Transcript
