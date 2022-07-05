$PackageName = "MSApps_Business_DE_x64"

$Path_4netIntune = "$Env:Programfiles\4net\EndpointManager"
Start-Transcript -Path "$Path_4netIntune\Log\$PackageName-install.log" -Force

$ConfigXml = "C:\Scripts\Office365Install\MSApps_Business_DE_x64.xml"
New-Item -ItemType File -Path $ConfigXml -Force
Copy-Item ".\MSApps_Business_DE_x64.xml" -Destination $ConfigXml -Force -Recurse
.\Install-Office365Suite.ps1 -ConfigurationXMLFile $ConfigXml -CleanUpInstallFiles

Stop-Transcript
