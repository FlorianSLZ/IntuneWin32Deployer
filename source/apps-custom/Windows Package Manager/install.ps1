$PackageName = "WindowsPackageManager"
$Package_winget = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$Package_VCLibs = "VCLibs140.appx"
$URL_winget = "https://aka.ms/getwinget"
$URL_VCLibs = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$ProgramName-install.log" -Force

# Force using TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##############################################################################
#   Install VCLibs
##############################################################################
# Program/Installation folder
$Folder_install = "$Path_local\Data\$Package_VCLibs"
New-Item -Path $Folder_install -ItemType Directory -Force -Confirm:$false

# Download current VCLibs MSIXBundle
$wc = New-Object net.webclient
$wc.Downloadfile($URL_winget, "$Folder_install\$Package_VCLibs")

# Install VCLibs MSIXBundle 
try{
    Add-AppxPackage -Path "$Folder_install\$Package_VCLibs" 
    Write-Host "Installation of $Package_VCLibs finished"
}catch{
    Write-Error "Failed to install $Package_VCLibs!"
} 

# Install file cleanup
Start-Sleep 3 # to unblock installation file
Remove-Item -Path "$Folder_install" -Force -Recurse

# check installation of VCLibs
if(!$(Get-AppxPackage -Name 'Microsoft.VCLibs.140.00.UWPDesktop' -ErrorAction SilentlyContinue)){exit 1}


##############################################################################
#   Install winget
##############################################################################
# Program/Installation folder
$Folder_install = "$Path_local\Data\$PackageName"
New-Item -Path $Folder_install -ItemType Directory -Force -Confirm:$false

# Download current winget MSIXBundle
$wc = New-Object net.webclient
$wc.Downloadfile($URL_winget, "$Folder_install\$Package_winget")

# Install WinGet MSIXBundle 
try{
    Add-AppxProvisionedPackage -Online -PackagePath "$Folder_install\$Package_winget" -SkipLicense
    Start-Sleep -Seconds 3
    Add-AppxPackage -Path "$Folder_install\$Package_winget" -ForceUpdateFromAnyVersion -ForceApplicationShutdown
    Write-Host "Installation of $PackageName finished"
}catch{
    Write-Error "Failed to install $PackageName!"
} 

# Install file cleanup
Start-Sleep 3 # to unblock installation file
Remove-Item -Path "$Folder_install" -Force -Recurse


Stop-Transcript