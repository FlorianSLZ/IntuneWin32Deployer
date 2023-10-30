function Publish-IWDWin32App{
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER AppInfo
        xxxx


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [array]$AppInfo,

        [parameter(Mandatory = $false, HelpMessage = "Local output folder for intunewins")]
        [ValidateNotNullOrEmpty()]
        [string]$IntunewinOutput = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer\_intunewin",

        [parameter(Mandatory = $false, HelpMessage = "Fallback Image URL for App icons")]
        [ValidateNotNullOrEmpty()]
        [string]$AppIconFallback = "https://raw.githubusercontent.com/FlorianSLZ/scloud/main/img/app.png"

    )

    try{
        

        Write-Host "Reading all apps from Intune ..."  -ForegroundColor Gray
        Connect-MSIntuneGraph -TenantID $Global:AccessTokenTenantID -Refresh | Out-Null
        $IntuneApps_all = Get-IntuneWin32App

        Write-Host "Processing App: $($AppInfo.Name) " -ForegroundColor Cyan

        # Get local App folder
        $AppFolder = Get-IWDLocalApp -Name $($AppInfo.Name)

        Connect-MSIntuneGraph -TenantID $Global:AccessTokenTenantID -Refresh | Out-Null

        # Check if app already existis in Intune
        $update = "N"
        if($AppInfo.Name -in $IntuneApps_all.DisplayName){
            Write-Host "   App $($AppInfo.Name) already exists in Intune" -ForegroundColor Yellow
            $update = Read-Host "   Do you want to update the app? [Y/N]"
            if($update -eq "Y"){
                $CurrentIntuneApp = Get-IntuneWin32App -DisplayName $AppInfo.Name
            }else {
                Write-Host "   Skipping app $($AppInfo.Name)" -ForegroundColor Yellow
                break
            }
            
        }
        # clean up old Intune file
        $FileName = "$IntunewinOutput\$($AppInfo.Name).intunewin"
        if (Test-Path $FileName) { Remove-Item $FileName }

        # Create intunewin file
        $IntuneWinNEW = New-IntuneWin32AppPackage -SourceFolder $($AppFolder.FullName) -SetupFile $($AppInfo.InstallFile) -OutputFolder $IntunewinOutput 
        Rename-Item -Path $IntuneWinNEW.Path -NewName "$($AppInfo.Name).intunewin"

        $IntuneWinFile = (Get-ChildItem $IntunewinOutput -Filter "$($AppInfo.Name).intunewin").FullName

        # Create requirement rule for all platforms and Windows 10 2004
        $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedWindowsRelease "W10_2004"

        # Registry detection
        if($AppInfo.detection.keyPath){
            if($AppInfos.detection.operationType -eq "exists"){$DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -Existence -KeyPath $($AppInfos.detection.Registry.RegistryKeyPath) -DetectionType $($AppInfos.detection.Registry.RegistryDetectionType) }
            elseif($AppInfos.detection.operationType -eq "string"){$DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -StringComparison -KeyPath $($AppInfo.detection.keyPath) -ValueName $($AppInfo.detection.valueName)  -StringComparisonOperator $($AppInfo.detection.operator)  -StringComparisonValue $($AppInfo.detection.comparisonValue) }
        }
        # File/Folder detection
        elseif($AppInfo.detection.fileOrFolderName){
            switch ($AppInfo.detection.operationType) {
                Existence { $DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -Path $($AppInfo.detection.Path) -FileOrFolder $($AppInfo.detection.fileOrFolderName) -DetectionType $($AppInfo.detection.operationType) -Check32BitOn64System $($AppInfo.detection.Check32BitOn64System) }
                Version { $DetectionRule = New-IntuneWin32AppDetectionRuleFile -Version -Path $($AppInfo.detection.Path) -FileOrFolder $($AppInfo.detection.fileOrFolderName) -DetectionType $($AppInfo.detection.operationType) -Check32BitOn64System $($AppInfo.detection.Check32BitOn64System) -Operator $($AppInfo.detection.operator) -VersionValue $($AppInfo.detection.comparisonValue)}
                Default { Write-Error "Detection Rule not supported" }
            }
        }
        # Script detection
        elseif($AppInfo.detection.scriptContent){
            $DetectionScriptFile = (Get-ChildItem $AppFolder.FullName -Filter "$($AppInfo.detection.scriptContent)").FullName
            $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $DetectionScriptFile -EnforceSignatureCheck $false -RunAs32Bit $false
        }else{
            Write-Error "Detection Rule not supported"
        }
        
        
        # install command
        $InstallCommandLine = $AppInfo.InstallCmdLine
        $UninstallCommandLine = $AppInfo.UninstallCmdLine

        # check for png or jpg
        $Icon_path = (Get-ChildItem "$($AppFolder.FullName)\*" -Include "*.jpg", "*.png" | Select-Object -First 1).FullName
        if(!$Icon_path){
            $Icon_path = "$env:temp\app.png"
            Invoke-WebRequest -Uri $AppIconFallback -OutFile $Icon_path
        }
        $Icon = New-IntuneWin32AppIcon -FilePath $Icon_path

        if($update -eq "Y"){
            $AppUpload = Update-IntuneWin32AppPackageFile -ID $CurrentIntuneApp.id -FilePath $IntuneWinFile
            Write-Verbose $AppUpload
            $DetectionUpdate = Set-IntuneWin32AppDetectionRule -ID $CurrentIntuneApp.id -DetectionRule $DetectionRule
            Write-Verbose $DetectionUpdate
            $AppUpdate = Set-IntuneWin32App -ID $CurrentIntuneApp.id -DisplayName $AppInfo.Name -Description $AppInfo.Description -AppVersion $AppInfo.Version -Publisher $AppInfo.Publisher
            Write-Verbose $AppUpdate
        }else{
            $AppUpload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $AppInfo.Name -Description $AppInfo.Description -AppVersion $AppInfo.Version -Publisher $AppInfo.Publisher -InstallExperience $($AppInfo.InstallExperience) -Icon $Icon -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine
            Write-Verbose $AppUpload
        }
    }
    catch{
        Write-Host "Error application $($AppInfo.Name) " -ForegroundColor Red
        $_
    }
    # Sleep to prevent block from azure on a mass upload
    Start-sleep -s 3

    try{
        # Check dependency
        if($AppInfo.dependency){
            Write-Host "  Processing dependency $($AppInfo.dependency) to $($AppInfo.Name)" -ForegroundColor Cyan
            $Session = Connect-MSIntuneGraph -TenantID $SettingsVAR.Tenant
            Write-Verbose $Session
            
            $UploadedApp = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.Name} | Select-Object name, id
            $DependendProgram = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.dependency} | Select-Object name, id
            if(!$DependendProgram){
                Write-Host "    dependent program $($AppInfo.dependency) is not present in the MEM enviroment, please create/upload first." -ForegroundColor Orange
            }
            $DependendProgram = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.dependency} | Select-Object name, id
            $Dependency = New-IntuneWin32AppDependency -id $DependendProgram.id -DependencyType AutoInstall
            $UploadProcess = Add-IntuneWin32AppDependency -id $UploadedApp.id -Dependency $Dependency
            Write-Verbose $UploadProcess
            Write-Host "  Added dependency $($AppInfo.dependency) to $($AppInfo.Name)" -ForegroundColor Cyan
        }
    }catch{
        Write-Host "Error adding dependency for $($AppInfo.Name)" -ForegroundColor Red
        $_
    }

    if($($global:SettingsVAR.AADgrp) -eq "True"){Add-AADGroup $AppInfo}
    if($($global:SettingsVAR.AADuninstallgrp) -eq "True"){Add-AADUninstallGroup $AppInfo}

}
