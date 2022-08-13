$PackageName = "WindowsPackageManager"
$Path_4Log = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_4netIntune\Log\uninstall\$PackageName-uninstall.log" -Force

Remove-AppPackage -Package "Microsoft.DesktopAppInstaller"

Stop-Transcript
