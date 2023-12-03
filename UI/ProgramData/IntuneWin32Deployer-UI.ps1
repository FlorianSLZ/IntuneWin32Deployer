#For TESTING
$ModulePath = "C:\Users\florian.salzmann\OneDrive - UMB AG\Dokumente\_TMP\DEV_Intune-Win32-Deployer-main\Module\IntuneWin32Deployer"
#$ModulePath = "C:\Users\WDAGUtilityAccount\Desktop\DEV_Intune-Win32-Deployer-main\Module\IntuneWin32Deployer"
Import-Module -Name $ModulePath -Verbose -Force

# Module fixes
#. $PSScriptRoot\fixes\IntuneWin32App\Invoke-IntuneGraphRequest.ps1
. $PSScriptRoot\fixes\IntuneWin32App\Set-IntuneWin32AppDetectionRule.ps1
# . $PSScriptRoot\fixes\IntuneWin32App\Get-IntuneWin32AppRelationExistence.ps1

# UI Framework
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms


#create window
$inputXML = Get-Content "$PSScriptRoot\xaml\main.xaml"
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
   }
}

############################################ Functions ####################################################

function Show-AppGridView(){
    # Set the default sidebar selection (All)
    $var_sidebar.SelectedIndex = 0
}


function Show-SettingsPopup {
    # XAML for the popup window
    $popupXaml = Get-Content "$PSScriptRoot\xaml\settings.xaml"

    if(!$(Test-Path $global:GlobalSettingsFilePath))
    {
        # initial settings
        $AppSettings = @{
            "RepoPath" = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer"
        }
    }
    else {
        $AppSettings = Get-Content -Raw -Path $global:GlobalSettingsFilePath | ConvertFrom-Json
    }

    # Convert the XAML to a WPF Window object
    $xamlContext = [Windows.Markup.XamlReader]::Parse($popupXaml)

    # Get controls from the XAML
    $input_repoPath = $xamlContext.FindName('input_repoPath')
    $btn_Save = $xamlContext.FindName('btn_Save')

    # Event handler for the OK button
    $btn_Save.Add_Click({
        # You can access the input values using $input_repoPath.Text and $input_tenantID.Text here.
        # Add your logic to handle the input fields.
        $AppSettings.RepoPath = $input_repoPath.Text

        $AppSettings | ConvertTo-Json | Out-File $global:GlobalSettingsFilePath -Force 

        $xamlContext.Close()
    })

    $input_repoPath.Text = $AppSettings.RepoPath

    # Show the popup
    $null = $xamlContext.ShowDialog()
}

function Show-UserPopup {
    # XAML for the popup window
    $popupXaml = Get-Content "$PSScriptRoot\xaml\user.xaml"

    # Convert the XAML to a WPF Window object
    $xamlContext = [Windows.Markup.XamlReader]::Parse($popupXaml)

    # Get controls from the XAML
    $text_ClientId = $xamlContext.FindName('text_ClientId')
    $text_TenantId = $xamlContext.FindName('text_TenantId')
    $text_Account = $xamlContext.FindName('text_Account')
    $text_Scopes = $xamlContext.FindName('text_Scopes')
    $button_Close = $xamlContext.FindName('button_Close')
    $button_Logoff = $xamlContext.FindName('button_LogOff')
    $button_ReAuth = $xamlContext.FindName('button_reAuth')

    # Event handler for the Close button
    $button_Close.Add_Click({
        $xamlContext.Close()
    })

    # Event handler for the Logoff button
    $button_Logoff.Add_Click({
        Disconnect-Graph  
        $xamlContext.Close()
    })

    # Event handler for the Re-Auth button
    $button_ReAuth.Add_Click({
        $var_overlayText.Text = "Connecting to Tenant..."
        $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible
        
        Connect-IWD
    
        $var_button_login.Content = "$($(Get-MGContext).Account)"
    
        $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden

        $xamlContext.Close()
    })

    # Set Text
    $MGContext = Get-MGContext
    $text_ClientId.Text = $MGContext.ClientId
    $text_TenantId.Text = $MGContext.TenantId
    $text_Account.Text = $MGContext.Account
    $text_Scopes.Text = $MGContext.Scopes

    # Show the popup
    $null = $xamlContext.ShowDialog()
}

function Show-JsonEditor {
    param (
        [string]$AppInfo
    )

    # Read the XAML content from the file
    $xamlFilePath = "$PSScriptRoot\xaml\editApp.xaml"
    $xamlContent = Get-Content -Path $xamlFilePath -Raw

    # Load the XAML content and create a form object
    $JsonEditorWindow = [Windows.Markup.XamlReader]::Parse($xamlContent)

    # Function to handle the Save button click event
    $buttonSave_Click = {
        # Get the JSON properties from the textboxes and convert them to a PowerShell object
        $jsonObject = @{
            "Name" = $JsonEditorWindow.textbox_Name.Text
            "xxx" = $JsonEditorWindow.textbox_xxx.Text
        }

        # Convert the PowerShell object back to JSON format
        $updatedJson = $jsonObject | ConvertTo-Json -Depth 10

        # Do something with the updated JSON, e.g., write to a file, display, etc.
        Write-Host $updatedJson
    }

    # Assign the script block to the Save button click event
    $JsonEditorWindow.button_Save.Add_Click($buttonSave_Click)

    # Show the form
    $JsonEditorWindow.ShowDialog()
}


  

###########################################################################################################
#   Sidebar
###########################################################################################################
# Add a SelectionChanged event handler
$var_sidebar.Add_SelectionChanged({
    $selectedItem = $var_sidebar.SelectedItem
    $selectedTextBlock = $selectedItem.Content
    $selectedText = $selectedTextBlock.Text

    switch ($selectedText) {
        "All" {
            $var_button_addApp.Visibility = [System.Windows.Visibility]::Hidden
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Hidden
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Visible

            $AllLocalApps = @()
            $AllLocalApps += Get-IWDLocalApp -All -Meta
            $var_dataGrid_Apps.ItemsSource = $AllLocalApps
        }
        "Winget" {
            $SelectedLocalApps = @()
            $SelectedLocalApps += Get-IWDLocalApp -Type winget -Meta
            $var_dataGrid_Apps.ItemsSource = $SelectedLocalApps

            $var_button_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Hidden
        }
        "Chocolatey" {
            $SelectedLocalApps = @()
            $SelectedLocalApps += Get-IWDLocalApp -Type choco -Meta
            $var_dataGrid_Apps.ItemsSource = $SelectedLocalApps

            $var_button_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Hidden
        }
        "Custom" {
            $SelectedLocalApps = @()
            $SelectedLocalApps += Get-IWDLocalApp -Type custom -Meta
            $var_dataGrid_Apps.ItemsSource = $SelectedLocalApps

            $var_button_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Hidden
        }
    }
})


###########################################################################################################
#   Main
###########################################################################################################

$var_button_addApp.Add_Click{
    # call add function
    $selectedItem = $var_sidebar.SelectedItem
    $selectedTextBlock = $selectedItem.Content
    $selectedText = $selectedTextBlock.Text
    $Type = $selectedText

    if($Type -eq "Chocolatey"){$Type="choco"}

    # Set the text in the overlay
    $var_overlayText.Text = "Adding App: $($var_text_addApp.Text) ($Type)"
    $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible
    # Command
    Add-IWDApp -AppName $var_text_addApp.Text -Type $Type

    $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden

    # re-load apps for overview
    Show-AppGridView
}

$var_button_uploadApp.Add_Click{
    
    $var_overlayText.Text = "Uploading App: `n$($var_dataGrid_Apps.SelectedItem.displayName)"
    $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible 
    $var_overlayText.Text = "Uploading App: `n$($var_dataGrid_Apps.SelectedItem.displayName)"
    
    # upload to intune
    Publish-IWDWin32App -AppInfo $var_dataGrid_Apps.SelectedItem

    $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden
}

$var_button_removeApp.Add_Click{
    
    # Popup message
    $messageBoxText = "Do you really want to remove this app? `n`n$($var_dataGrid_Apps.SelectedItem.displayName)"
    $caption = "Remove App"
    $button = [Windows.MessageBoxButton]::YesNo
    $icon = [Windows.MessageBoxImage]::Warning
    $result = [Windows.MessageBox]::Show($messageBoxText, $caption, $button, $icon)

    if($result -eq "Yes"){     
        # remove app
        Get-IWDLocalApp -displayName $var_dataGrid_Apps.SelectedItem.displayName -Folder | Remove-Item -Force -Recurse
        Show-AppGridView
    }

}

$var_button_help.Add_Click{
    Start-Process "https://scloud.work/category/intunewin32-deployer/"
}

$var_button_settings.Add_Click{

    $var_overlayText.Text = "Settings are open"
    $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible

    Show-SettingsPopup

    $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden

}

$var_button_login.Add_Click{

    $MGContext = Get-MGContext

    if($MGContext -ne $null){

        $var_overlayText.Text = "User infos are open"
        $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible

        Show-UserPopup

        $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden

    }else{
        $var_overlayText.Text = "Connecting to Tenant..."
        $var_overlayBox.Visibility = [System.Windows.Visibility]::Visible
        
        Connect-IWD
    
        $var_button_login.Content = "$($(Get-MGContext).Account)"
    
        $var_overlayBox.Visibility = [System.Windows.Visibility]::Hidden
    }
}



$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"


# First Run
if(!$(Get-IWDSettings))
{
    # initialize settings
    Set-IWDSettings
}

Write-Host "The 'Intune Win32 Deployer' is ready. `nThis window will show you some additional process details and logs. " -ForegroundColor Cyan

# Open GUI
Show-AppGridView
$Null = $window.ShowDialog()
