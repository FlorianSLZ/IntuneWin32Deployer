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


# System Rquiremend
Function Check-SystemRequirements() {

    # Modules?

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
    
    <#
    ##############Define text label3
    
    $textLabel3 = New-Object "System.Windows.Forms.Label";
    $textLabel3.Left = 25;
    $textLabel3.Top = 95;
    $textLabel3.Text = $lb3;

    ##############Define text label4
    $textLabel4 = New-Object "System.Windows.Forms.Label";
    $textLabel4.Left = 25;
    $textLabel4.Top = 135;
    $textLabel4.Text = $lb4;

    ##############Define text label5
    $textLabel5 = New-Object "System.Windows.Forms.Label";
    $textLabel5.Left = 25;
    $textLabel5.Top = 175;
    $textLabel5.Text = $lb5;
    #>
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
    
    <#
    ############Define text box3 for input
    $textBox3 = New-Object "System.Windows.Forms.TextBox";
    $textBox3.Left = 150;
    $textBox3.Top = 90;
    $textBox3.width = 200;

    ############Define text box4 for input
    $textBox4 = New-Object "System.Windows.Forms.TextBox";
    $textBox4.Left = 150;
    $textBox4.Top = 130;
    $textBox4.width = 200;

    ############Define text box5 for input
    $textBox5 = New-Object "System.Windows.Forms.TextBox";
    $textBox5.Left = 150;
    $textBox5.Top = 170;
    $textBox5.width = 200;
    #>
    #############Define default values for the input boxes
    $textBox1.Text = $global:TenantName;
    $textBox2.Text = $global:Publisher;
    
    #############define OK button
    $button = New-Object "System.Windows.Forms.Button";
    $button.Left = 360;
    $button.Top = 170;
    $button.Width = 100;
    $button.Text = "Speichern";
    
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

function Get-MAorSUS {
    # Fenster Gundgerüst - Nachfrage MA or SuS importieren
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $FormMAorSus = New-Object System.Windows.Forms.Form
    $FormMAorSus.Backcolor = $Color_bg
    $FormMAorSus.StartPosition = "CenterScreen"
    $FormMAorSus.Size = New-Object System.Drawing.Size(400, 100)
    $FormMAorSus.Text = "Mitarbeiter oder SuS importieren?"
    $FormMAorSus.Icon = $global:ProgramIcon
    ###################################################################################################################

    # Button "MAs einlesen"
    $ButtonMAeinlesen = New-Object System.Windows.Forms.Button
    $ButtonMAeinlesen.Location = New-Object System.Drawing.Size(20, 25)
    $ButtonMAeinlesen.Size = New-Object System.Drawing.Size(100, 25)
    $ButtonMAeinlesen.Text = "Mitarbeiter"
    $ButtonMAeinlesen.Name = "Mitarbeiter"
    $ButtonMAeinlesen.backcolor = $Color_Button
    $ButtonMAeinlesen.Add_MouseHover( {$ButtonMAeinlesen.backcolor = $Color_ButtonHover})
    $ButtonMAeinlesen.Add_MouseLeave( {$ButtonMAeinlesen.backcolor = $Color_Button})
    $ButtonMAeinlesen.Add_Click({$global:MAorSuS = "MA";$FormMAorSus.Close()})
    $FormMAorSus.Controls.Add($ButtonMAeinlesen)

    # Button "SuS einlesen"
    $ButtonSuSeinlesen = New-Object System.Windows.Forms.Button
    $ButtonSuSeinlesen.Location = New-Object System.Drawing.Size(140, 25)
    $ButtonSuSeinlesen.Size = New-Object System.Drawing.Size(100, 25)
    $ButtonSuSeinlesen.Text = "SuS"
    $ButtonSuSeinlesen.Name = "SuS"
    $ButtonSuSeinlesen.backcolor = $Color_Button
    $ButtonSuSeinlesen.Add_MouseHover( {$ButtonSuSeinlesen.backcolor = $Color_ButtonHover})
    $ButtonSuSeinlesen.Add_MouseLeave( {$ButtonSuSeinlesen.backcolor = $Color_Button})
    $ButtonSuSeinlesen.Add_Click({$global:MAorSuS = "SuS";$FormMAorSus.Close()})
    $FormMAorSus.Controls.Add($ButtonSuSeinlesen)

    # Button "Abbrechen"
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(260, 25)
    $CancelButton.Size = New-Object System.Drawing.Size(100, 25)
    $CancelButton.Text = "Abbrechen"
    $CancelButton.Name = "Abbrechen"
    $CancelButton.DialogResult = "Cancel"
    $CancelButton.backcolor = $Color_Button
    $CancelButton.Add_MouseHover( {$CancelButton.backcolor = $Color_ButtonHover})
    $CancelButton.Add_MouseLeave( {$CancelButton.backcolor = $Color_Button})
    $CancelButton.Add_Click({$FormMAorSus.Close()})
    $FormMAorSus.Controls.Add($CancelButton)
    # Fenster anzeigen
    [void] $FormMAorSus.ShowDialog()
}



function Get-FinishMessage () {
    # Fenster Gundgerüst
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $FormFinishMessage = New-Object System.Windows.Forms.Form
    $FormFinishMessage.Backcolor = $Color_bg
    $FormFinishMessage.StartPosition = "CenterScreen"
    $FormFinishMessage.Size = New-Object System.Drawing.Size(300, 400)
    $FormFinishMessage.Text = "Import abgeschlossen"
    $FormFinishMessage.Icon = $global:ProgramIcon
    ###################################################################################################################

    # Button "Erstellte Benutzer"
    $ButtonErstellteUser = New-Object System.Windows.Forms.Button
    $ButtonErstellteUser.Location = New-Object System.Drawing.Size(75, 50)
    $ButtonErstellteUser.Size = New-Object System.Drawing.Size(150, 25)
    $ButtonErstellteUser.Text = "Erstellte Benutzer"
    $ButtonErstellteUser.Name = "Erstellte Benutzer"
    $ButtonErstellteUser.backcolor = $Color_Button
    $ButtonErstellteUser.Add_MouseHover( {$ButtonErstellteUser.backcolor = $Color_ButtonHover})
    $ButtonErstellteUser.Add_MouseLeave( {$ButtonErstellteUser.backcolor = $Color_Button})
    $ButtonErstellteUser.Add_Click( {Start-Process $global:UserSummaryLocation})
    $FormFinishMessage.Controls.Add($ButtonErstellteUser)

    # Button "Schliessen"
    $FinishButton = New-Object System.Windows.Forms.Button
    $FinishButton.Location = New-Object System.Drawing.Size(100, 300)
    $FinishButton.Size = New-Object System.Drawing.Size(100, 25)
    $FinishButton.Text = "Schliessen"
    $FinishButton.Name = "Schliessen"
    $FinishButton.DialogResult = "Cancel"
    $FinishButton.backcolor = $Color_Button
    $FinishButton.Add_MouseHover( {$FinishButton.backcolor = $Color_ButtonHover})
    $FinishButton.Add_MouseLeave( {$FinishButton.backcolor = $Color_Button})
    $FinishButton.Add_Click( {$FormFinishMessage.Close()})
    $FormFinishMessage.Controls.Add($FinishButton)
    # Fenster anzeigen
    [void] $FormFinishMessage.ShowDialog()
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
. "$global:ProgramPath\Intune-Win32-Deployer.ps1" -TenantName $global:TenantName -Publisher $global:Publisher

# Colors
$Color_Button = "#0288d1"
$Color_ButtonHover = "#4fc3f7"
$Color_bg = "#121212"
$Color_warning = "#f44336"
$Color_error = "#ffa726"

# Main window
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objForm = New-Object System.Windows.Forms.Form
$objForm.Backcolor = $Color_bg
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(800, 400)
$objForm.Text = "Intune win32 Deployer"
$objForm.Icon = $global:ProgramIcon

# Button "Deploy from personal Catalog"
$Button_Deploy = New-Object System.Windows.Forms.Button
$Button_Deploy.Location = New-Object System.Drawing.Size(30, 30)
$Button_Deploy.Size = New-Object System.Drawing.Size(200, 30)
$Button_Deploy.Text = "Deploy from personal Catalog"
$Button_Deploy.Name = "Deploy from personal Catalog"
$Button_Deploy.backcolor = $Color_Button
$Button_Deploy.Add_MouseHover( {$Button_Deploy.backcolor = $Color_ButtonHover})
$Button_Deploy.Add_MouseLeave( {$Button_Deploy.backcolor = $Color_Button})
$Button_Deploy.Add_Click( {Import-FromCatalog})
$objForm.Controls.Add($Button_Deploy)

# Button "Add Chocolatey App"
$Button_AddChoco = New-Object System.Windows.Forms.Button
$Button_AddChoco.Location = New-Object System.Drawing.Size(30, 70)
$Button_AddChoco.Size = New-Object System.Drawing.Size(200, 30)
$Button_AddChoco.Text = "Add Chocolatey App"
$Button_AddChoco.Name = "Add Chocolatey App"
$Button_AddChoco.backcolor = $Color_Button
$Button_AddChoco.Add_MouseHover( {$Button_AddChoco.backcolor = $Color_ButtonHover})
$Button_AddChoco.Add_MouseLeave( {$Button_AddChoco.backcolor = $Color_Button})
$Button_AddChoco.Add_Click( {SearchAdd-ChocoApp})
$objForm.Controls.Add($Button_AddChoco)

# Button "Add Winget App"
$Button_AddWinget = New-Object System.Windows.Forms.Button
$Button_AddWinget.Location = New-Object System.Drawing.Size(30, 110)
$Button_AddWinget.Size = New-Object System.Drawing.Size(200, 30)
$Button_AddWinget.Text = "Add Winget App"
$Button_AddWinget.Name = "Add Winget App"
$Button_AddWinget.backcolor = $Color_Button
$Button_AddWinget.Add_MouseHover( {$Button_AddWinget.backcolor = $Color_ButtonHover})
$Button_AddWinget.Add_MouseLeave( {$Button_AddWinget.backcolor = $Color_Button})
$Button_AddWinget.Add_Click( {SearchAdd-WinGetApp} )
$objForm.Controls.Add($Button_AddWinget)


# Info Tenant
$Label_Tenant = New-Object System.Windows.Forms.Label
$Label_Tenant.Location = New-Object System.Drawing.Size(30, 200)
$Label_Tenant.Size = New-Object System.Drawing.Size(200, 30)
$Label_Tenant.Text = "Tenant: $($global:TenantName)"
$Label_Tenant.ForeColor = "#FFFFFF"
$objForm.Controls.Add($Label_Tenant)

# Info Publisher
$Label_Publisher = New-Object System.Windows.Forms.Label
$Label_Publisher.Location = New-Object System.Drawing.Size(30, 230)
$Label_Publisher.Size = New-Object System.Drawing.Size(200, 30)
$Label_Publisher.Text = "Publisher: $($global:Publisher)"
$Label_Publisher.ForeColor = "#FFFFFF"
$objForm.Controls.Add($Label_Publisher)


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
$objForm.Controls.Add($Button_Change)

# Button "Cancel"
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(300, 300)
$CancelButton.Size = New-Object System.Drawing.Size(100, 25)
$CancelButton.Text = "Cancel"
$CancelButton.Name = "Cancel"
$CancelButton.DialogResult = "Cancel"
$CancelButton.backcolor = $Color_Button
$CancelButton.Add_MouseHover( {$CancelButton.backcolor = $Color_ButtonHover})
$CancelButton.Add_MouseLeave( {$CancelButton.backcolor = $Color_Button})
$CancelButton.Add_Click( {$objForm.Close()})
$objForm.Controls.Add($CancelButton)
# show window
[void] $objForm.ShowDialog()
