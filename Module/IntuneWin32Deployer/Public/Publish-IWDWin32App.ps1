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
        [parameter(Mandatory = $true, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$AppInfo,

        [parameter(Mandatory = $false, HelpMessage = "Local output folder for intunewins")]
        [ValidateNotNullOrEmpty()]
        [string]$IntunewinOutput = "$Global:GlobalRepoPath\_intunewin",

        [parameter(Mandatory = $false, HelpMessage = "Fallback Image URL for App icons")]
        [ValidateNotNullOrEmpty()]
        [string]$AppIconFallback = "https://raw.githubusercontent.com/FlorianSLZ/scloud/main/img/app.png"

    )

    try{
        

        Write-Host "Reading all apps from Intune ..."  -ForegroundColor Gray
        Invoke-IWDLoginRequest
        $IntuneApps_all = Get-IntuneWin32App

        Write-Host "Processing App: $($AppInfo.displayName) " -ForegroundColor Cyan

        # Get local App folder
        $AppFolder = Get-IWDLocalApp -displayName $($AppInfo.displayName) -Folder

        Invoke-IWDLoginRequest

        # Check if app already existis in Intune
        if($AppInfo.displayName -in $IntuneApps_all.DisplayName){

            $messageBoxText = "App already exists in Intune.`n> $($AppInfo.displayName)`n`nDo you want to update it?"
            $caption = "Remove App"
            $button = [Windows.MessageBoxButton]::YesNo
            $icon = [Windows.MessageBoxImage]::Warning
            $update = [Windows.MessageBox]::Show($messageBoxText, $caption, $button, $icon)

            if($update -eq "Yes"){
                $CurrentIntuneApp = Get-IntuneWin32App -DisplayName $AppInfo.displayName
            }else {
                Write-Host "   Skipping app $($AppInfo.displayName)" -ForegroundColor Yellow
                break
            }
            
        }
        # clean up old Intune file
        $FileName = "$IntunewinOutput\$($AppInfo.displayName).intunewin"
        if (Test-Path $FileName) { Remove-Item $FileName }

        # Create intunewin file
        $IntuneWinNEW = New-IntuneWin32AppPackage -SourceFolder $($AppFolder) -SetupFile $($AppInfo.InstallFile) -OutputFolder $IntunewinOutput 
        Rename-Item -Path $IntuneWinNEW.Path -NewName "$($AppInfo.displayName).intunewin"

        $IntuneWinFile = (Get-ChildItem $IntunewinOutput -Filter "$($AppInfo.displayName).intunewin").FullName

        # Create requirement rule for all platforms and Windows 10 2004
        $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture $($AppInfo.applicableArchitectures) -MinimumSupportedWindowsRelease $($AppInfo.minimumSupportedWindowsRelease)

        # Registry detection
        if($AppInfo.rules.keyPath){
            if($AppInfo.rules.operationType -eq "exists"){$DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -Existence -KeyPath $($AppInfo.rules.RegistryKeyPath) -DetectionType $($AppInfo.rules.RegistryDetectionType) }
            elseif($AppInfo.rules.operationType -eq "string"){$DetectionRule = New-IntuneWin32AppDetectionRuleRegistry -StringComparison -KeyPath $($AppInfo.rules.keyPath) -ValueName $($AppInfo.rules.valueName)  -StringComparisonOperator $($AppInfo.rules.operator) -StringComparisonValue $($AppInfo.rules.comparisonValue) }
        }
        # File/Folder detection
        elseif($AppInfo.rules.fileOrFolderName){
            switch ($AppInfo.rules.operationType) {
                exists { $DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -Path $($AppInfo.rules.path) -FileOrFolder $($AppInfo.rules.fileOrFolderName) -DetectionType $($AppInfo.rules.operationType) -Check32BitOn64System $($AppInfo.rules.Check32BitOn64System) }
                version { $DetectionRule = New-IntuneWin32AppDetectionRuleFile -Version -Path $($AppInfo.rules.path) -FileOrFolder $($AppInfo.rules.fileOrFolderName) -DetectionType $($AppInfo.rules.operationType) -Check32BitOn64System $($AppInfo.rules.Check32BitOn64System) -Operator $($AppInfo.rules.operator) -VersionValue $($AppInfo.rules.comparisonValue)}
                Default { Write-Error "Detection Rule not supported" }
            }
        }
        # Script detection
        elseif($AppInfo.rules.scriptContent){
            $DetectionScriptFile = (Get-ChildItem $AppFolder -Filter "$($AppInfo.rules.scriptContent)").FullName
            $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $DetectionScriptFile -EnforceSignatureCheck $([System.Convert]::ToBoolean($AppInfo.rules.enforceSignatureCheck)) -RunAs32Bit $([System.Convert]::ToBoolean($AppInfo.rules.runAs32Bit))
        }else{
            Write-Error "Detection Rule not supported"
        }

        # check for png or jpg
        $Icon_path = (Get-ChildItem "$($AppFolder)\*" -Include "*.jpg", "*.png" | Select-Object -First 1).FullName
        if(!$Icon_path){
            $Icon_path = "$env:temp\app.png"
            Invoke-WebRequest -Uri $AppIconFallback -OutFile $Icon_path
        }
        $Icon = New-IntuneWin32AppIcon -FilePath $Icon_path

        if($update -eq "Yes"){
            $AppUpload = Update-IntuneWin32AppPackageFile -ID $CurrentIntuneApp.id -FilePath $IntuneWinFile
            Write-Verbose $AppUpload
            $DetectionUpdate = Set-IntuneWin32AppDetectionRule -ID $CurrentIntuneApp.id -DetectionRule $DetectionRule
            Write-Verbose $DetectionUpdate
            $null = Set-IntuneWin32App `
                            -ID $CurrentIntuneApp.id `
                            -DisplayName $AppInfo.displayName `
                            -Description $AppInfo.description `
                            -AppVersion $AppInfo.Version `
                            -Publisher $AppInfo.Publisher 

            #Write-Verbose $AppUpdate
        }else{
            $null = Add-IntuneWin32App `
                            -FilePath $IntuneWinFile `
                            -DisplayName $AppInfo.displayName `
                            -Description $AppInfo.description `
                            -AppVersion $AppInfo.Version `
                            -Publisher $AppInfo.Publisher `
                            -InstallExperience $($AppInfo.InstallExperience.runAsAccount) `
                            -Icon $Icon `
                            -RestartBehavior $($AppInfo.InstallExperience.deviceRestartBehavior) `
                            -DetectionRule $DetectionRule `
                            -RequirementRule $RequirementRule `
                            -InstallCommandLine $AppInfo.installCommandLine `
                            -UninstallCommandLine $AppInfo.uninstallCommandLine

            #Write-Verbose $AppUpload
        }
    }
    catch{
        Write-Error "Error application $($AppInfo.displayName) `n$_" 

    }
    # Sleep to prevent block from azure on a mass upload
    Start-sleep -s 3

    try{
        # Check dependency
        if($AppInfo.dependency){
            Write-Host "  Processing dependency $($AppInfo.dependency) to $($AppInfo.displayName)" -ForegroundColor Cyan
            Invoke-IWDLoginRequest
            
            $UploadedApp = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.displayName} 
            $DependendProgram = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.dependency} 
            if(!$DependendProgram){
                if($AppInfo.dependency -eq "Windows Package Manager"){
                    Add-IWDwinget4Dependency
                }elseif($AppInfo.dependency -eq "Chocolatey"){
                    Add-IWDChocolatey4Dependency
                }else{
                    Write-Host "    Dependent program is not present in the Intune enviroment, please create/upload first.`n   $($AppInfo.dependency)" -ForegroundColor Yellow
                }

                $DependendProgram = Get-IntuneWin32App | Where-Object {$_.DisplayName -eq $AppInfo.dependency} 

            }

            $Dependency = New-IntuneWin32AppDependency -id $DependendProgram.id -DependencyType AutoInstall -ErrorAction SilentlyContinue
            $Dependencies = @($Dependency)
            Add-IntuneWin32AppDependency -id $UploadedApp.id -Dependency $Dependencies
            Write-Host "  Added dependency $($AppInfo.dependency) to $($AppInfo.displayName)" -ForegroundColor Cyan
            
        }
    }catch{
        Write-Error "Error adding dependency for $($AppInfo.displayName) `n$_" 
        
    }

    if($($global:SettingsVAR.AADgrp) -eq "True"){Add-AADGroup $AppInfo}
    if($($global:SettingsVAR.AADuninstallgrp) -eq "True"){Add-AADUninstallGroup $AppInfo}

    Write-Host "  App $($AppInfo.displayName) processed" -ForegroundColor Green

}
