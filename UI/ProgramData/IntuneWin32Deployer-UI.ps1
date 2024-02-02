Start-Transcript "$env:temp\IntuneWin32Deployer.log"

# UI Framework
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms


###########################################################################################################
#   Functions 
###########################################################################################################

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
        $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "Connecting to Tenant..."
        
        
        Connect-IWD
    
        $var_button_login.Content = "$($(Get-MGContext).Account)"
    
        $global:messageScreen.Hide()

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

function Get-MessageScreen {
    param (
        [Parameter(Mandatory = $true)]
        [String]$xamlPath
    )
    
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    Add-Type -AssemblyName PresentationFramework
    [xml]$xaml = Get-Content $xamlPath
    $global:messageScreen = ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml)))
    [System.Windows.Forms.Application]::DoEvents()
}

function Get-LoadingMessageScreen {
    param (
            [Parameter(Mandatory = $true)]
            [String]$xamlPath
    )

    Get-MessageScreen -xamlPath $xamlPath
    $global:messageScreenTitle = $global:messageScreen.FindName("TextMessageHeader")
    $global:messageScreenText = $global:messageScreen.FindName("TextMessageBody")
    $global:button1 = $global:messageScreen.FindName("ButtonMessage1")
    $global:button2 = $global:messageScreen.FindName("ButtonMessage2")

    $global:messageScreenTitle.Text = "Initializing Device Troubleshooter"
    $global:messageScreenText.Text = "Starting Device Troubleshooter"
    [System.Windows.Forms.Application]::DoEvents()
    $global:messageScreen.Show() | Out-Null
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-MessageScreenText {
    param (
        [Parameter(Mandatory = $true)]
        [String]$text,
        [String]$header
    )

    if ($header) { $global:messageScreenTitle.Text = $header }
    $global:messageScreenText.Text = $text
    [System.Windows.Forms.Application]::DoEvents()
}

function Import-AllModules {

    Import-Module IntuneWin32Deployer

    # Module fixes
    #. $PSScriptRoot\fixes\IntuneWin32App\Invoke-IntuneGraphRequest.ps1
    . $PSScriptRoot\fixes\IntuneWin32App\Set-IntuneWin32AppDetectionRule.ps1
    # . $PSScriptRoot\fixes\IntuneWin32App\Get-IntuneWin32AppRelationExistence.ps1
    
    return $true

}

function Exit-Error {
    param (
        [Parameter(Mandatory = $true)]
        [String]$text
    )

    Write-Error $text 
    $global:messageScreen.Hide()
    $global:formAuth.Hide()
    Exit
}





# open message screen
Get-LoadingMessageScreen -xamlPath ("$PSScriptRoot\xaml\message.xaml")
$global:messageScreen.Show()
        Set-MessageScreenText -text "Starting IntuneWin32 Deployer" -header "Initializing IntuneWin32 Deployer UI"

# Load modules
$global:messageScreen.Show()
        Set-MessageScreenText -text "Load all required modules"
if (-not (Import-AllModules)) { Exit-Error -text "Error while loading the modules" }

# Init settings
$global:messageScreen.Show()
        Set-MessageScreenText -text "Initialize Settings"
if(!$(Get-IWDSettings))
{
    # initialize settings
    Set-IWDSettings
}






###########################################################################################################
#   Main
###########################################################################################################
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
    $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "Adding App: $($var_text_addApp.Text) ($Type)"
    
    # Command
    Add-IWDApp -AppName $var_text_addApp.Text -Type $Type

    $global:messageScreen.Hide()

    # re-load apps for overview
    Show-AppGridView
}

$var_button_uploadApp.Add_Click{
    
    $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "Uploading App: `n$($var_dataGrid_Apps.SelectedItem.displayName)"
     
    $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "Uploading App: `n$($var_dataGrid_Apps.SelectedItem.displayName)"
    
    # upload to intune
    Publish-IWDWin32App -AppInfo $var_dataGrid_Apps.SelectedItem

    $global:messageScreen.Hide()
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

    $global:messageScreen.Show()
    Set-MessageScreenText -Header "Doing some magic" -Text "Just kidding, Settings are open. "
    

    Show-SettingsPopup

    $global:messageScreen.Hide()

}

$var_button_login.Add_Click{

    $MGContext = Get-MGContext

    if($MGContext -ne $null){

        $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "User infos are open"

        Show-UserPopup

        $global:messageScreen.Hide()

    }else{
        $global:messageScreen.Show()
        Set-MessageScreenText -Header "Doing some magic" -Text "Connecting to Tenant..."
        
        Connect-IWD
    
        $var_button_login.Content = "$($(Get-MGContext).Account)"
    
        $global:messageScreen.Hide()
    }
}



$var_text_copyright.Text = "Florian Salzmann | scloud.work | v0.1"





###########################################################################################################
#   Start UI
###########################################################################################################



# Init Ui
$global:messageScreen.Show()
        Set-MessageScreenText -Text "Initialize User Interface"

# Open GUI
Show-AppGridView
$global:messageScreen.Hide()
$Null = $window.ShowDialog()


Stop-Transcript
Write-Host "Saving log..." -ForegroundColor Cyan
