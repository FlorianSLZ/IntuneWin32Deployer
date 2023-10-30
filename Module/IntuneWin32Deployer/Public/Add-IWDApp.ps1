function Add-IWDApp{
    
    <#
    .SYNOPSIS
        Adds applications to a repository and, if desired, creates IntuneWin packages.

    .DESCRIPTION
        This function allows you to add applications to a repository, either using Chocolatey or Winget as the package manager. 
        It provides an interactive selection process for adding applications and optionally creating IntuneWin packages.

    .PARAMETER AppName
        An array of application names to add.

    .PARAMETER type
        Specifies the package manager to use, either "choco" for Chocolatey or "winget" for Winget.

    .PARAMETER PropertyName3
        A switch parameter. If provided, it indicates whether to create IntuneWin packages for the added applications.

    .EXAMPLE
        Example 1:
        Add-IWDApp -AppName @("app1", "app2") -type "choco" -PropertyName3

        This command adds the Chocolatey applications "app1" and "app2" to the repository and creates IntuneWin packages for them.

    .EXAMPLE
        Example 2:
        Add-IWDApp -AppName "app3" -type "winget"

        This command adds the Winget application "app3" to the repository.

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-09-12

    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "The name of the app.")]
        [ValidateNotNullOrEmpty()]
        [array]$AppName,

        [parameter(Mandatory = $true, HelpMessage = "Specifies the package manager to use, either 'choco' for Chocolatey or 'winget' for Winget.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("choco", "winget", "custom")]
        [string]$Type
    )
    
    try{

        switch ($Type) {
        "choco"  {
            # Chocolatey
            $ChocoApp = choco search $AppName | Out-GridView -OutputMode Single -Title "Select Applications to add"
            
            # parameter mapping
            $ChocoApp_ID = $($ChocoApp.split(' ')[0])
            $detectionJSON = @"
{
    "ruleType": "detection",
    "path": "C:\\ProgramData\\chocolatey\\lib",
    "fileOrFolderName": "$ChocoApp_ID",
    "check32BitOn64System": false,
    "operationType": "exists",
    "operator": "notConfigured",
    "comparisonValue": null
}
"@ | ConvertFrom-Json
            
            
            # get frendly name
            $ChocoDetails = '(' + $((choco search $ChocoApp_ID --by-id-only --exact -v) -join '|') + ')'
            $pos = $ChocoDetails.IndexOf("Title:")
            $ChocoDescriptionPlus = $ChocoDetails.Substring($pos+7)
            $pos = $ChocoDescriptionPlus.IndexOf(" |")
            $Choco_Name = $ChocoDescriptionPlus.Substring(0, $pos)


            # get frendly description
            $ChocoDetails = '(' + $((choco search $ChocoApp_ID --by-id-only --exact -v) -join '|') + ')'
            $pos = $ChocoDetails.IndexOf("Description:")
            $ChocoDescriptionPlus = $ChocoDetails.Substring($pos+13)
            $pos = $ChocoDescriptionPlus.IndexOf("|")
            $Choco_Description = $ChocoDescriptionPlus.Substring(0, $pos)

            # Create App array
            $ChocoApp_new = New-Object PsObject -Property @{ 
                id = "$ChocoApp_ID"; 
                Type = "choco"; 
                Name = $Choco_Name;
                Version = "choco auto";
                Description = $Choco_Description;
                Detection = $detectionJSON;
                InstallExperience = "system"
                Dependency = "Chocolatey"
                InstallFile = "install.ps1"
            }
            
            # Create App localy
            $NewApp = Save-IWDWin32App -Type choco -AppPackage $ChocoApp_new

            # xy added, wanna deploy?
            $deployYN = New-Object -ComObject Wscript.Shell
            if($($deployYN.Popup("Chocolatey App *$ChocoApp_ID* added. `nDo you want to create the intunewin?",0,"Create App",64+4)) -eq 6){
                # Trigger creation process
                Publish-IWDWin32App $NewApp
                Add-IWDChocolatey4Dependency
                Publish-IWDWin32App -AppInfo $ChocoApp_new
            }

            break
        }
            
        "winget"   {
            # Winget
            $winget2add = winget search --id $AppName --exact --accept-source-agreements
            if($winget2add -like "*$AppName*"){

                # parameter mapping
                $detectionJSON = @"
{
    "ruleType": "detection",
    "check32BitOn64System": false,
    "enforceSignatureCheck": false,
    "scriptContent": "winget-detection.ps1"
}
"@ | ConvertFrom-Json
            
            
                # get frendly name
                $WingetDetails = $(winget search --id $($AppName) --exact)
                $WingetDetails = '(' + $($WingetDetails -join '|') + ')'
                $pos = $WingetDetails.IndexOf("-|")
                $WingetDescriptionPlus = $WingetDetails.Substring($pos+2)
                $pos = $WingetDescriptionPlus.IndexOf(" $($AppName)")
                $winget_name = $WingetDescriptionPlus.Substring(0, $pos)

                # set Description
                $winget_Description = "Installation via Windows Package Manager (winget)"

                # Create App array
                $winget_new = New-Object PsObject -Property @{ 
                    id = "$AppName"; 
                    Type = "choco"; 
                    Name = $winget_name;
                    Version = "winget auto";
                    Description = $winget_Description;
                    Detection = $detectionJSON;
                    InstallExperience = "system"
                    Dependency = "Windows Package Manager"
                    InstallFile = "install.ps1"
                }


                # Create App localy
                $NewApp = Save-IWDWin32App -Type winget -AppPackage $winget_new

                # xy added, wanna deploy?
                $deployYN = New-Object -ComObject Wscript.Shell
                if($($deployYN.Popup("Winget App *$AppName* added. `nDo you want to create the intunewin?",0,"Create App",64+4)) -eq 6){
                    # Trigger creation process
                    Publish-IWDWin32App $NewApp
                    Add-IWDChocolatey4Dependency
                    Publish-IWDWin32App -AppInfo $winget_new
                }

            }else{
                Write-Error "ID not found!"
            }
            
             break
            }
        default {Write-Error "Something went wrong. Unsuported type."; break}
        }

        
    }catch{
        Write-Error "Error while processing $PropertyName1 `n$_"
    }

}
