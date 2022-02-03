$PackageName = "WindowsPackageManager"
$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\$PackageName-install.log" -Force

Add-AppPackage -path "Microsoft.DesktopAppInstaller.msixbundle"

Stop-Transcript
