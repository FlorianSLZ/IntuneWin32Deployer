#For TESTING
Import-Module -Name "C:\GitHub\DEV_Intune-Win32-Deployer\Module\IntuneWin32Deployer" -Verbose -Force

&.\fixes\IntuneWin32App\Invoke-IntuneGraphRequest.ps1
&.\fixes\IntuneWin32App\Set-IntuneWin32AppDetectionRule.ps1
&.\fixes\IntuneWin32App\Get-IntuneWin32AppRelationExistence.ps1

# UI Framework
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$SettingsFile = ".\settings.json"


#create window
$inputXML = Get-Content ".\xaml\main.xaml"
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
    $popupXaml = Get-Content ".\xaml\settings.xaml"

    if(!$(Test-Path $SettingsFile))
    {
        # initial settings
        $AppSettings = @{
            "RepoPath" = "$([Environment]::GetFolderPath("MyDocuments"))\IntuneWin32Deployer"
            "IntuneTenant" = "YourPrefix.onmicrosoft.com"
        }
    }
    else {
        $AppSettings = Get-Content -Raw -Path $SettingsFile | ConvertFrom-Json
    }

    # Convert the XAML to a WPF Window object
    $xamlContext = [Windows.Markup.XamlReader]::Parse($popupXaml)

    # Get controls from the XAML
    $input_repoPath = $xamlContext.FindName('input_repoPath')
    $input_tenantID = $xamlContext.FindName('input_tenantID')
    $btn_Save = $xamlContext.FindName('btn_Save')

    # Event handler for the OK button
    $btn_Save.Add_Click({
        # You can access the input values using $input_repoPath.Text and $input_tenantID.Text here.
        # Add your logic to handle the input fields.
        $AppSettings.RepoPath = $input_repoPath.Text
        $AppSettings.IntuneTenant = $input_tenantID.Text

        $AppSettings | ConvertTo-Json | Out-File $SettingsFile -Force 

        $xamlContext.Close()
    })

    $input_repoPath.Text = $AppSettings.RepoPath
    $input_tenantID.Text = $AppSettings.IntuneTenant

    # Show the popup
    $null = $xamlContext.ShowDialog()
}

function Show-JsonEditor {
    param (
        [string]$AppInfo
    )

    # Read the XAML content from the file
    $xamlFilePath = ".\xaml\editApp.xaml"
    $xamlContent = Get-Content -Path $xamlFilePath -Raw

    # Load the XAML content and create a form object
    $JsonEditorWindow = [Windows.Markup.XamlReader]::Parse($xamlContent)

    # Function to handle the Save button click event
    $buttonSave_Click = {
        # Get the JSON properties from the textboxes and convert them to a PowerShell object
        $jsonObject = @{
            "Name" = $JsonEditorWindow.textbox_Name.Text
            "EvergreenName" = $JsonEditorWindow.textbox_EvergreenName.Text
            # Add other JSON properties here
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
    switch ($selectedItem.Content) {
        "All" {
            $var_button_addApp.Visibility = [System.Windows.Visibility]::Hidden
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Hidden
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Visible

            $AllLocalApps = Get-IWDLocalApp -All -Meta
            $var_dataGrid_Apps.ItemsSource = $AllLocalApps
        }
        "Winget" {
            $SelectedLocalApps = Get-IWDLocalApp -Type winget -Meta
            $var_dataGrid_Apps.ItemsSource = $SelectedLocalApps

            $var_button_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Hidden
        }
        "Chocolatey" {
            $SelectedLocalApps = Get-IWDLocalApp -Type choco -Meta
            $var_dataGrid_Apps.ItemsSource = $SelectedLocalApps

            $var_button_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addApp.Visibility = [System.Windows.Visibility]::Visible
            $var_text_addInfo.Visibility = [System.Windows.Visibility]::Hidden
        }
        "Custom" {
            $SelectedLocalApps = Get-IWDLocalApp -Type custom -Meta
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
    $Type = $var_sidebar.SelectedItem.Content
    if($Type -eq "Chocolatey"){$Type="choco"}
    write-Host $Type
    Add-IWDApp -AppName $var_text_addApp.Text -Type $Type

    # re-load apps for overview
    Show-AppGridView
}

$var_button_UploadApp.Add_Click{
    # select app
    Get-IWDLocalApp -Name $var_dataGrid_Apps.SelectedItem.Content
    # upload to intune
    Publish-LIWDWin32App -choose selected
}

$var_button_help.Add_Click{
    Start-Process "https://scloud.work/IntuneWin32Deployer"
}

$var_button_settings.Add_Click{
    Show-SettingsPopup
}

$var_button_settings.Add_Click{
    $AppInfo = Get-LocalEvergreenApp -AppName $($selectedName) -Meta
    Show-editApp -AppInfo $AppInfo
}

$var_button_login.Add_Click{
    Connect-IWD
}


$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"


# First Run
if(!$(Test-Path $SettingsFile))
{
    # open settings
    Show-SettingsPopup
}

# Open GUI
Show-AppGridView
$Null = $window.ShowDialog()