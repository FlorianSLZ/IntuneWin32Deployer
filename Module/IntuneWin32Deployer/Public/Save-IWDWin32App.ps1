function Save-IWDWin32App{
    
    <#
    .SYNOPSIS
        xxxx

    .DESCRIPTION
        xxxx
        
    .PARAMETER PropertyName1
        xxxx

    .PARAMETER PropertyName2
        xxx

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "xxx")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("choco", "winget", "custom")]
        [string]$Type,

        [parameter(Mandatory = $true, HelpMessage = "An array of the application to add to the repository.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$AppPackage,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath = $Global:GlobalRepoPath,

        [parameter(Mandatory = $false, HelpMessage = "Local Repo Path where the Apps and template are stored")]
        [ValidateNotNullOrEmpty()]
        [string]$IWDPath = $global:GlobalIWDPath,

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Template_main = "$IWDPath\templates\main",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$AppInfo_main = "$Template_main\AppInfo.json",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Installer_main = "$Template_main\install.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Uninstaller_main = "$Template_main\uninstall.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Installer_choco = "$IWDPath\templates\choco\choco-installer.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Uninstaller_choco = "$IWDPath\templates\choco\choco-uninstaller.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Installer_winget = "$IWDPath\templates\winget\winget-installer.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Uninstaller_winget = "$IWDPath\templates\winget\winget-uninstaller.ps1",

        [parameter(Mandatory = $false, HelpMessage = "xxxxxxxx")]
        [ValidateNotNullOrEmpty()]
        [string]$Detection_winget = "$IWDPath\templates\winget\winget-detection.ps1"

    )

    try{

        switch ($Type) {
        "choco"  {
            Write-Host "Create local package for $($AppPackage.displayName) (Package Manager: Chocolatey)" -Foregroundcolor cyan
            $AppPackage
            # Set and create program folder
            $AppFolderPath = "$RepoPath\$($AppPackage.displayName)"
            New-Item $AppFolderPath -type Directory -Force | Out-Null
            
            # copy main installer files
            Copy-Item -Path "$Template_main\*" -Destination $AppFolderPath
            
            # Read the content of "installer.ps1" and "choco-installer.ps1"
            $InstallerContent_main = Get-Content -Path $Installer_main
            $InstallerContent_choco = Get-Content -Path $Installer_choco
            
            # Join the content from booth array into a single string
            $InstallerContent_main = $InstallerContent_main -join [Environment]::NewLine
            $InstallerContent_choco = $InstallerContent_choco -join [Environment]::NewLine
            
            # Create install file
            $InstallerContent_main -replace "(?s)## THE INSTALLATION  ##", $InstallerContent_choco | Out-File "$AppFolderPath\install.ps1" -Encoding utf8
            

            # Read the content of "uninstaller.ps1" and "choco-uninstaller.ps1"
            $UninstallerContent_main = Get-Content -Path $Uninstaller_main
            $UninstallerContent_choco = Get-Content -Path $Uninstaller_choco
            
            # Join the content from booth array into a single string
            $UninstallerContent_main = $UninstallerContent_main -join [Environment]::NewLine
            $UninstallerContent_choco = $UninstallerContent_choco -join [Environment]::NewLine
            
            # create uninstall file
            $UninstallerContent_main -replace "(?s)## THE UNINSTALLATION  ##", $UninstallerContent_choco | Out-File "$AppFolderPath\uninstall.ps1" -Encoding utf8

            
            # Set AppInfo file
            $AppInfo_file = "$AppFolderPath\AppInfo.json"
            $AppInfo = Get-Content $AppInfo_file -Raw | ConvertFrom-Json

            
            # Merge the two JSON objects
            $AppInfo.PSObject.Properties | ForEach-Object {
                $propertyName = $_.Name
                if ($AppPackage.PSObject.Properties[$propertyName]) {
                    $AppInfo.$propertyName = $AppPackage.$propertyName
                }
            }

            
            # Convert the merged object back to JSON
            $mergedInfo = $AppInfo | ConvertTo-Json

            # Save the merged JSON to a new file or overwrite one of the existing files
            $mergedInfo | Out-File $AppInfo_file -Force 

            return $($mergedInfo | ConvertFrom-Json)

            break
            }
            
        "winget"
        {
            Write-Host "Create win32 package for $($AppPackage.id) (Microsoft Package Manager)" -Foregroundcolor cyan

            # Set and create program folder
            $AppFolderPath = "$RepoPath\$($AppPackage.displayName)"
            New-Item $AppFolderPath -type Directory -Force | Out-Null

            # copy main installer files
            Copy-Item -Path "$Template_main\*" -Destination $AppFolderPath

            # Read the content of "installer.ps1" and "winget-installer.ps1"
            $InstallerContent_main = Get-Content -Path $Installer_main
            $InstallerContent_winget = Get-Content -Path $Installer_winget

            # Join the content from booth array into a single string
            $InstallerContent_main = $InstallerContent_main -join [Environment]::NewLine
            $InstallerContent_winget = $InstallerContent_winget -join [Environment]::NewLine

            # Create install file
            $InstallerContent_main -replace "(?s)## THE INSTALLATION  ##", $InstallerContent_winget | Out-File "$AppFolderPath\install.ps1" -Encoding utf8


            # Read the content of "uninstaller.ps1" and "winget-uninstaller.ps1"
            $UninstallerContent_main = Get-Content -Path $Uninstaller_main
            $UninstallerContent_winget = Get-Content -Path $Uninstaller_winget

            # Join the content from booth array into a single string
            $UninstallerContent_main = $UninstallerContent_main -join [Environment]::NewLine
            $UninstallerContent_winget = $UninstallerContent_winget -join [Environment]::NewLine

            # create uninstall file
            $UninstallerContent_main -replace "(?s)## THE UNINSTALLATION  ##", $UninstallerContent_winget | Out-File "$AppFolderPath\uninstall.ps1" -Encoding utf8
            
            # create detection file
            $(Get-Content "$Detection_winget").replace("WINGETPROGRAMID","$($AppPackage.id)")  | Out-File "$AppFolderPath\winget-detection.ps1" -Encoding utf8

            # Set AppInfo file
            $AppInfo_file = "$AppFolderPath\AppInfo.json"
            $AppInfo = Get-Content $AppInfo_file -Raw | ConvertFrom-Json

            # Merge the two JSON objects
            $AppInfo.PSObject.Properties | ForEach-Object {
                $propertyName = $_.Name
                if ($AppPackage.PSObject.Properties[$propertyName]) {
                    $AppInfo.$propertyName = $AppPackage.$propertyName
                }
            }
            
            # Add properties from $AppPackage that don't exist in $AppInfo
            $AppPackage.PSObject.Properties | ForEach-Object {
                $propertyName = $_.Name
                if (-not $AppInfo.PSObject.Properties[$propertyName]) {
                    $AppInfo | Add-Member -MemberType NoteProperty -Name $propertyName -Value $AppPackage.$propertyName
                }
            }


            # Convert the merged object back to JSON
            $mergedInfo = $AppInfo | ConvertTo-Json

            # Save the merged JSON to a new file or overwrite one of the existing files
            $mergedInfo | Out-File $AppInfo_file -Force 
            
            break
            }
        "custom"
        {
            Write-Host "Create win32 package for $($AppPackage.displayName) (custom, no Package Manager)" -Foregroundcolor cyan

            # Set and create program folder
            $AppFolderPath = "$RepoPath\$($AppPackage.displayName)"
            New-Item $AppFolderPath -type Directory -Force | Out-Null

            # copy main installer files
            Copy-Item -Path "$Template_main\*" -Destination $AppFolderPath

            # Set AppInfo file
            $AppInfo_file = "$AppFolderPath\AppInfo.json"
            $AppInfo = Get-Content $AppInfo_file -Raw | ConvertFrom-Json

            # Merge the two JSON objects
            $AppInfo.PSObject.Properties | ForEach-Object {
                $propertyName = $_.Name
                if ($AppPackage.PSObject.Properties[$propertyName]) {
                    $AppInfo.$propertyName = $AppPackage.$propertyName
                }
            }

            # Convert the merged object back to JSON
            $mergedInfo = $AppInfo | ConvertTo-Json

            # Save the merged JSON to a new file or overwrite one of the existing files
            $mergedInfo | Out-File $AppInfo_file -Force 

            break


        }
        default {Write-Error "Something went wrong. Unsuported type."; break}
        }


        
    }catch{
        Write-Error "Error while processing $($AppPackage.displayName) `n$_"
    }

}
