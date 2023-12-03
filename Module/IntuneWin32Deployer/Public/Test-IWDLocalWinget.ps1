function Test-IWDLocalWinget{
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER PropertyName1


    #>

    param (

    )
    try{

        # Check if Winget is installed
        $CheckWinget = winget 
        if (!$CheckWinget){

            Read-Host "Winget is missing on this machine. Press [Enter] to install ot [CRTL]+[C] to abort"

            $progressPreference = 'silentlyContinue'
            Write-Information "Downloading WinGet and its dependencies..."
            Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
            Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
            Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
            Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
            Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
            Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        }
        
        
    }catch{
        Write-Error "Error while check/install winget `n$_"
    }

}
