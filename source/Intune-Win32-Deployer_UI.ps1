#############################################################################################################
#
#   Tool:       Intune Win32 Deployer - UI
#   Author:     Florian Salzmann
#   Website:    http://www.scloud.work
#   Twitter:    https://twitter.com/FlorianSLZ
#   LinkedIn:   https://www.linkedin.com/in/fsalzmann/
#
#############################################################################################################

# Basic Variables 
$global:ProgramPath = "$env:LOCALAPPDATA\Intune-Win32-Deployer"
$global:ProgramVar = $global:ProgramPath + '\ressources\variables.xml'
$global:ProgramIcon = $global:ProgramPath + '\ressources\Intune-Win32-Deployer.ico'
$global:intunewinOnly = $false
$global:Status = "ready"
# Colors
$global:Color_Button = "#0288d1"
$global:Color_ButtonHover = "#4fc3f7"
$global:Color_bg = "#121212"
$global:Color_warning = "#f44336"
$global:Color_error = "#ffa726"


# System Rquiremend
Function Check-SystemRequirements() {

    # Modules?

} 

Function Restart-MainUI {
    try{
        $MainUI.Close()
        $MainUI.Dispose()
    
        Start-MainUI

    }catch{}
}

function Status-Wrapper ($function2call){
    $global:Status = "working..."
    $Label_Status.Text = "Status: $($global:Status)"
    $Label_Status.ForeColor = "#ff9900"
    $MainUI.Controls.Add($Label_Status)
    Invoke-Expression $function2call
    $global:Status = "ready"
    $Label_Status.Text = "Status: $($global:Status)"
    $Label_Status.ForeColor = "#009933"
    $MainUI.Controls.Add($Label_Status)
    Write-Host "Done. Ready for next task. "
}

# Einlesen der Initial Variabeln (OU Pfade, Lizenzgruppen)
Function Get-InitialVariables() {
    if(![System.IO.File]::Exists($global:ProgramVar)){
        
    }
    else {
        $InitialVAR = Import-Clixml -Path $global:ProgramVar 
        $global:TenantName = $InitialVAR.TenantName
        $global:Publisher = $InitialVAR.Publisher

    }
    

    # Pop up um Variabeln anzupassen
    $NewInitialVariables = Get-ProgramVar "Type in your data" "Tenantname" "Publisher"
    $global:TenantName = $NewInitialVariables[0]
    $global:Publisher = $NewInitialVariables[1]


    $InitialVariables = New-Object psobject -Property @{TenantName = $global:TenantName; Publisher = $global:Publisher}
    Export-Clixml -Path $global:ProgramVar -InputObject $InitialVariables -Force

    Restart-MainUI

} 

# PopUP für die Initial Variabeln (GUI) 
function Get-ProgramVar ($title, $lb1, $lb2, $lb3, $lb4, $lb5) {

    ###################Load Assembly for creating form & button######
    [void][System.Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName( "Microsoft.VisualBasic")
    
    #####Define the form size & placement
    $form = New-Object "System.Windows.Forms.Form";
    $form.Width = 500;
    $form.Height = 250;
    $form.Text = $title;
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
    
    ##############Define text label1
    $textLabel1 = New-Object "System.Windows.Forms.Label";
    $textLabel1.Left = 25;
    $textLabel1.Top = 15;
    $textLabel1.Text = $lb1;
    
    ##############Define text label2
    $textLabel2 = New-Object "System.Windows.Forms.Label";
    $textLabel2.Left = 25;
    $textLabel2.Top = 55;
    $textLabel2.Text = $lb2;
    
    ############Define text box1 for input
    $textBox1 = New-Object "System.Windows.Forms.TextBox";
    $textBox1.Left = 150;
    $textBox1.Top = 10;
    $textBox1.width = 200;
    
    ############Define text box2 for input
    
    $textBox2 = New-Object "System.Windows.Forms.TextBox";
    $textBox2.Left = 150;
    $textBox2.Top = 50;
    $textBox2.width = 200;
    
    #############Define default values for the input boxes
    $textBox1.Text = $global:TenantName;
    $textBox2.Text = $global:Publisher;
    
    #############define OK button
    $button = New-Object "System.Windows.Forms.Button";
    $button.Left = 360;
    $button.Top = 170;
    $button.Width = 100;
    $button.Text = "Save";
    
    ############# This is when you have to close the form after getting values
    $eventHandler = [System.EventHandler] {
        $textBox1.Text;
        $textBox2.Text;
        $textBox3.Text;
        $textBox4.Text;
        $textBox5.Text;
        $form.Close(); };
    
    $button.Add_Click($eventHandler) ;
    
    #############Add controls to all the above objects defined
    $form.Controls.Add($button);
    $form.Controls.Add($textLabel1);
    $form.Controls.Add($textLabel2);
    $form.Controls.Add($textLabel3);
    $form.Controls.Add($textLabel4);
    $form.Controls.Add($textLabel5);
    $form.Controls.Add($textBox1);
    $form.Controls.Add($textBox2);
    $form.Controls.Add($textBox3);
    $form.Controls.Add($textBox4);
    $form.Controls.Add($textBox5);
    $ret = $form.ShowDialog();
    
    #################return values
    
    return $textBox1.Text, $textBox2.Text, $textBox3.Text, $textBox4.Text, $textBox5.Text
}

function SearchForm-AddApp ($title, $description, $onlinesearch_text, $onlinesearch_url){
    $form_AddApp = New-Object System.Windows.Forms.Form
    $form_AddApp.Text = $title
    $form_AddApp.Size = New-Object System.Drawing.Size(300,200)
    $form_AddApp.StartPosition = 'CenterScreen'

    $okButton_AddApp = New-Object System.Windows.Forms.Button
    $okButton_AddApp.Location = New-Object System.Drawing.Point(75,120)
    $okButton_AddApp.Size = New-Object System.Drawing.Size(75,23)
    $okButton_AddApp.Text = 'OK'
    $okButton_AddApp.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form_AddApp.AcceptButton = $okButton_AddApp
    $form_AddApp.Controls.Add($okButton_AddApp)

    $label_AddApp = New-Object System.Windows.Forms.Label
    $label_AddApp.Location = New-Object System.Drawing.Point(10,20)
    $label_AddApp.Size = New-Object System.Drawing.Size(280,20)
    $label_AddApp.Text = $description
    $form_AddApp.Controls.Add($label_AddApp)

    $textBox_AddApp = New-Object System.Windows.Forms.TextBox
    $textBox_AddApp.Location = New-Object System.Drawing.Point(10,40)
    $textBox_AddApp.Size = New-Object System.Drawing.Size(260,20)
    $form_AddApp.Controls.Add($textBox_AddApp)

    # Button "Find winget apps"
    $Button_SearchID = New-Object System.Windows.Forms.Button
    $Button_SearchID.Location = New-Object System.Drawing.Size(10, 80)
    $Button_SearchID.Size = New-Object System.Drawing.Size(260, 20)
    $Button_SearchID.Text = $onlinesearch_text
    $Button_SearchID.Name = $onlinesearch_text
    $Button_SearchID.backcolor = $Color_Button
    $Button_SearchID.Add_MouseHover( {$Button_SearchID.backcolor = $Color_ButtonHover})
    $Button_SearchID.Add_MouseLeave( {$Button_SearchID.backcolor = $Color_Button})
    $Button_SearchID.Add_Click( {Start-Process $onlinesearch_url} )
    $form_AddApp.Controls.Add($Button_SearchID)
    

    $form_AddApp.Topmost = $true

    $form_AddApp.Add_Shown({$textBox_AddApp.Select()})
    $result = $form_AddApp.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        if($title -like "*winget*"){SearchAdd-wingetApp $textBox_AddApp.Text}
        if($title -like "*Chocolatey*"){SearchAdd-ChocoApp $textBox_AddApp.Text}

    }
}

function Start-MainUI{

    # Color - variable
    if($global:intunewinonly -eq $true){$Button_intunewin_color  = "#EAB676"}else{$Button_intunewin_color  = "#A5A5A5"}
    
    # Main window
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $MainUI = New-Object System.Windows.Forms.Form
    $MainUI.Backcolor = $Color_bg
    $MainUI.StartPosition = "CenterScreen"
    $MainUI.Size = New-Object System.Drawing.Size(800, 400)
    $MainUI.Text = "Intune Win32 Deployer"
    $MainUI.Icon = $global:ProgramIcon

    # Button "Deploy from personal Catalog"
    $Button_Deploy = New-Object System.Windows.Forms.Button
    $Button_Deploy.Location = New-Object System.Drawing.Size(30, 30)
    $Button_Deploy.Size = New-Object System.Drawing.Size(200, 30)
    $Button_Deploy.Text = "Deploy from personal Catalog"
    $Button_Deploy.Name = "Deploy from personal Catalog"
    $Button_Deploy.backcolor = $Color_Button
    $Button_Deploy.Add_MouseHover( {$Button_Deploy.backcolor = $Color_ButtonHover})
    $Button_Deploy.Add_MouseLeave( {$Button_Deploy.backcolor = $Color_Button})
    $Button_Deploy.Add_Click( {Status-Wrapper "Import-FromCatalog"})
    $MainUI.Controls.Add($Button_Deploy)

    # Button "view personal Catalog"
    $Button_viewCatalog = New-Object System.Windows.Forms.Button
    $Button_viewCatalog.Location = New-Object System.Drawing.Size(240, 30)
    $Button_viewCatalog.Size = New-Object System.Drawing.Size(200, 30)
    $Button_viewCatalog.Text = "View App Catalog"
    $Button_viewCatalog.Name = "View App Catalog"
    $Button_viewCatalog.backcolor = $Color_Button
    $Button_viewCatalog.Add_MouseHover( {$Button_viewCatalog.backcolor = $Color_ButtonHover})
    $Button_viewCatalog.Add_MouseLeave( {$Button_viewCatalog.backcolor = $Color_Button})
    $Button_viewCatalog.Add_Click( {Status-Wrapper "Read-AppRepo | out-gridview"})
    $MainUI.Controls.Add($Button_viewCatalog)

    # Button "Add Chocolatey App"
    $Button_AddChoco = New-Object System.Windows.Forms.Button
    $Button_AddChoco.Location = New-Object System.Drawing.Size(30, 70)
    $Button_AddChoco.Size = New-Object System.Drawing.Size(200, 30)
    $Button_AddChoco.Text = "Add Chocolatey App"
    $Button_AddChoco.Name = "Add Chocolatey App"
    $Button_AddChoco.backcolor = $Color_Button
    $Button_AddChoco.Add_MouseHover( {$Button_AddChoco.backcolor = $Color_ButtonHover})
    $Button_AddChoco.Add_MouseLeave( {$Button_AddChoco.backcolor = $Color_Button})
    $Button_AddChoco.Add_Click( {Status-Wrapper 'SearchForm-AddApp "Add Chocolatey App" "Type in search string" "Find packages / id online" "https://community.chocolatey.org/packages"'})
    $MainUI.Controls.Add($Button_AddChoco)

    # Button "Add winget App"
    $Button_Addwinget = New-Object System.Windows.Forms.Button
    $Button_Addwinget.Location = New-Object System.Drawing.Size(30, 110)
    $Button_Addwinget.Size = New-Object System.Drawing.Size(200, 30)
    $Button_Addwinget.Text = "Add winget App"
    $Button_Addwinget.Name = "Add winget App"
    $Button_Addwinget.backcolor = $Color_Button
    $Button_Addwinget.Add_MouseHover( {$Button_Addwinget.backcolor = $Color_ButtonHover})
    $Button_Addwinget.Add_MouseLeave( {$Button_Addwinget.backcolor = $Color_Button})
    $Button_Addwinget.Add_Click( {Status-Wrapper 'SearchForm-AddApp "Add winget App" "Type in exact winget ID" "Find ID online" "https://winget.run"'} )
    $MainUI.Controls.Add($Button_Addwinget)

    # Info Tenant
    $Label_Tenant = New-Object System.Windows.Forms.Label
    $Label_Tenant.Location = New-Object System.Drawing.Size(30, 200)
    $Label_Tenant.Size = New-Object System.Drawing.Size(200, 30)
    $Label_Tenant.Text = "Tenant: $($global:TenantName)"
    $Label_Tenant.ForeColor = "#FFFFFF"
    $MainUI.Controls.Add($Label_Tenant)

    # Info Publisher
    $Label_Publisher = New-Object System.Windows.Forms.Label
    $Label_Publisher.Location = New-Object System.Drawing.Size(30, 230)
    $Label_Publisher.Size = New-Object System.Drawing.Size(200, 30)
    $Label_Publisher.Text = "Publisher: $($global:Publisher)"
    $Label_Publisher.ForeColor = "#FFFFFF"
    $MainUI.Controls.Add($Label_Publisher)

    # Info Status
    $Label_Status = New-Object System.Windows.Forms.Label
    $Label_Status.Location = New-Object System.Drawing.Size(500, 30)
    $Label_Status.Size = New-Object System.Drawing.Size(200, 30)
    $Label_Status.Text = "Status: $($global:Status)"
    $Label_Status.ForeColor = "#009933"
    $MainUI.Controls.Add($Label_Status)


    # Button "Change"
    $Button_Change = New-Object System.Windows.Forms.Button
    $Button_Change.Location = New-Object System.Drawing.Size(30, 260)
    $Button_Change.Size = New-Object System.Drawing.Size(200, 30)
    $Button_Change.Text = "Change"
    $Button_Change.Name = "Change"
    $Button_Change.backcolor = $Color_Button
    $Button_Change.Add_MouseHover( {$Button_Change.backcolor = $Color_ButtonHover})
    $Button_Change.Add_MouseLeave( {$Button_Change.backcolor = $Color_Button})
    $Button_Change.Add_Click( {Get-InitialVariables})
    $MainUI.Controls.Add($Button_Change)

    # Button "only intunewin"
    $Button_intunewin = New-Object System.Windows.Forms.Button
    $Button_intunewin.Location = New-Object System.Drawing.Size(250, 260)
    $Button_intunewin.Size = New-Object System.Drawing.Size(200, 30)
    $Button_intunewin.Text = "only create intunewin"
    $Button_intunewin.Name = "only create intunewin"
    $Button_intunewin.backcolor = $Button_intunewin_color
    $Button_intunewin.Add_MouseHover( {$Button_intunewin.backcolor = $Color_ButtonHover})
    $Button_intunewin.Add_MouseLeave( {$Button_intunewin.backcolor = $Button_intunewin_color})
    $Button_intunewin.Add_Click( {
        if($global:intunewinonly -eq $true){$global:intunewinonly = $false}else{$global:intunewinonly = $true}
        Restart-MainUI
    })
    $MainUI.Controls.Add($Button_intunewin) 

    # Button "Cancel"
    $Button_Cancel = New-Object System.Windows.Forms.Button
    $Button_Cancel.Location = New-Object System.Drawing.Size(300, 300)
    $Button_Cancel.Size = New-Object System.Drawing.Size(100, 25)
    $Button_Cancel.Text = "Cancel"
    $Button_Cancel.Name = "Cancel"
    $Button_Cancel.DialogResult = "Cancel"
    $Button_Cancel.backcolor = $Color_Button
    $Button_Cancel.Add_MouseHover( {$Button_Cancel.backcolor = $Color_ButtonHover})
    $Button_Cancel.Add_MouseLeave( {$Button_Cancel.backcolor = $Color_Button})
    $Button_Cancel.Add_Click( {$MainUI.Close()})
    $MainUI.Controls.Add($Button_Cancel)
    # show window
    [void] $MainUI.ShowDialog()

}

# functions - END
######################################################################################



# XML for Initial Variables
if(![System.IO.File]::Exists($global:ProgramVar)){
    Get-InitialVariables
}
else {
    $InitialVAR = Import-Clixml -Path $global:ProgramVar 
    $global:TenantName = $InitialVAR.TenantName
    $global:Publisher = $InitialVAR.Publisher
}

# Import functions
. "$global:ProgramPath\Intune-Win32-Deployer.ps1" -TenantName $global:TenantName -Publisher $global:Publisher -intunewinOnly $global:intunewinOnly

Start-MainUI