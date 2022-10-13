$PackageName = "WindowsPackageManager"
$Package_winget = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$URL_winget = "https://aka.ms/getwinget"
$URL_VCLibs = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$winget_minversion = "2022.927.3.0"

$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$PackageName-install.log" -Force

# Force using TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

##############################################################################
#   Check winget presence/version
##############################################################################
try{

    $winget_test = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "Microsoft.DesktopAppInstaller"}
    if([Version]$winget_test.Version -ge [version]$winget_minversion){
        Write-Host "Winget already installed with version: $($winget_test.Version)"
    }else{

        ##############################################################################
        #   Install winget
        ##############################################################################
        # Program/Installation folder
        $Folder_install = "$Path_local\Data\$PackageName"
        New-Item -Path $Folder_install -ItemType Directory -Force -Confirm:$false

        # Download current VCLibs appx
        Write-Host "Downloading stabel version of winget from: $($URL_winget)"
        $wc = New-Object System.Net.WebClient
        $wc.Downloadfile($URL_VCLibs, "$env:Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx")

        # Download current winget MSIXBundle
        Write-Host "Downloading stabel version of winget from: $($URL_winget)"
        $wc = New-Object System.Net.WebClient
        $wc.Downloadfile($URL_winget, "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")

        # Install Winget MSIXBundle 
        try{
            Add-AppxProvisionedPackage -Online -PackagePath "$env:Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -DependencyPackagePath "$env:Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx" -SkipLicense
            Start-Sleep -Seconds 3
            Write-Host "Installation of $PackageName finished"
        }catch{
            Write-Error "Failed to install $PackageName!"
        } 
    }

    ##############################################################################
    #   Winget settings > Machine context installation
    ##############################################################################
    # System Settings path 
    $SettingsPath = "$Env:windir\System32\config\systemprofile\AppData\Local\Microsoft\WinGet\Settings\settings.json"

    # Check if setting file exist, if not create it
    if(Test-Path $SettingsPath){
        $ConfigFile = Get-Content -Path $SettingsPath | Where-Object { $_ -notmatch '//' } | ConvertFrom-Json
    }
    if(!$ConfigFile){$ConfigFile = @{}  }

    if($ConfigFile.installBehavior.preferences){
        Add-Member -InputObject $ConfigFile.installBehavior.preferences -MemberType NoteProperty -Name 'scope' -Value 'Machine' -Force
    }else{
        $Scope = New-Object PSObject -Property $(@{scope = 'Machine' })
        $Preference = New-Object PSObject -Property $(@{preferences = $Scope })
        Add-Member -InputObject $ConfigFile -MemberType NoteProperty -Name 'installBehavior' -Value $Preference -Force
    }
    $ConfigFile | ConvertTo-Json | Out-File $SettingsPath -Encoding utf8 -Force
 

    New-Item -Path "$Path_local\Validation\$PackageName" -ItemType "file" -Force -Value $Package_winget

}catch{
    Write-Host "Failed to install $PackageName!"
    Write-Error $_
}
Stop-Transcript
