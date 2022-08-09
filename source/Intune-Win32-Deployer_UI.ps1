<#####################################################################################
                                                                     	       	    
		Titel:          GUI für UserCreation				                      		
		Autor:          Florian Salzmann		  						  			
		Firma:          4net AG                                           			                                    			                                         			
                                                                             		
        Description:    UI 
        
                                                                             		
#####################################################################################>

######################################################################################



# System Rquiremend
Function Check-SystemRequirements() {
    # Run as Admin?

    # Modules?

} 

# Einlesen der Initial Variabeln (OU Pfade, Lizenzgruppen)
Function Get-InitialVariables() {
    if(![System.IO.File]::Exists($global:InitialVariablesLocation)){
        
    }
    else {
        $InitialVAR = Import-Clixml -Path $global:InitialVariablesLocation 
        $global:Publisher = $InitialVAR.Publisher
        $global:TenantName = $InitialVAR.TenantName
    }
    

    # Pop up um Variabeln anzupassen
    $NewInitialVariables = PopUP "Daten eingeben" "AD Pfad SuS" "Lizenz Gruppe SuS" "AD Pfad MA" "Lizenz Gruppe MA" "AD Pfad Klassen"
    $global:ADPathSuS = $NewInitialVariables[0]
    $global:LizenzGroupSuS = $NewInitialVariables[1]
    $global:ADPathMA = $NewInitialVariables[2]
    $global:LizenzGroupMA = $NewInitialVariables[3]
    $global:KlassenOU = $NewInitialVariables[4]

    $InitialVariables = New-Object psobject -Property @{ADPathSuS = $global:ADPathSuS; ADPathMA = $global:ADPathMA; LizenzGroupSuS = $global:LizenzGroupSuS; LizenzGroupMA = $global:LizenzGroupMA;KlassenOU = $global:KlassenOU}
    Export-Clixml -Path $global:InitialVariablesLocation -InputObject $InitialVariables

} 

# PopUP für die Initial Variabeln (GUI) Quelle: https://syscloudpro.com/2014/03/11/powershell-custom-gui-input-box-for-passing-values-to-variables/ 
function PopUP ($title, $lb1, $lb2, $lb3, $lb4, $lb5) {

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
    
    #############Define default values for the input boxes
    $textBox1.Text = $global:ADPathSuS;
    $textBox2.Text = $global:LizenzGroupSuS;
    $textBox3.Text = $global:ADPathMA;
    $textBox4.Text = $global:LizenzGroupMA;
    $textBox5.Text = $global:KlassenOU;
    
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
    $FormMAorSus.Icon = $global:ProgrammPfad + "ProgrammData\img\4net.ico"
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
    $FormFinishMessage.Icon = $global:ProgrammPfad + "ProgrammData\img\4net.ico"
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

# Funktionen ENDE
######################################################################################

######################################################################################
# Basic Variables START
$global:ProgrammPfad = "C:\Users\Public\4net-UserCreation\"
# Data Stores
$global:InitialVariablesLocation = $global:ProgrammPfad + 'ProgrammData\InitialVariabeln.xml'
$global:CSV4Import = ""
$global:MAorSuS = ""

# XML für Initial Variables
if(![System.IO.File]::Exists($global:InitialVariablesLocation)){
    Get-InitialVariables
}
else {
    $InitialVAR = Import-Clixml -Path $global:InitialVariablesLocation 
    $global:ADPathSuS = $InitialVAR.ADPathSuS
    $global:ADPathMA = $InitialVAR.ADPathMA
    $global:LizenzGroupSuS = $InitialVAR.LizenzGroupSuS
    $global:LizenzGroupMA = $InitialVAR.LizenzGroupMA
    $global:KlassenOU = $InitialVAR.KlassenOU
}

# Basic Variables END
######################################################################################

######################################################################################


# Colors
$Color_Button = "#0288d1"
$Color_ButtonHover = "#4fc3f7"
$Color_bg = "#121212"
$Color_warning = "#f44336"
$Color_error = "#ffa726"

# Fenster Gundgerüst
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objForm = New-Object System.Windows.Forms.Form
$objForm.Backcolor = $Color_bg
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(800, 400)
$objForm.Text = "Intune win32 Deployer"
$objForm.Icon = $global:ProgrammPfad + "template\scloud.ico"

# Button "Deploy from personal Catalog"
$Button_Deploy = New-Object System.Windows.Forms.Button
$Button_Deploy.Location = New-Object System.Drawing.Size(30, 30)
$Button_Deploy.Size = New-Object System.Drawing.Size(200, 30)
$Button_Deploy.Text = "Deploy from personal Catalog"
$Button_Deploy.Name = "Deploy from personal Catalog"
$Button_Deploy.backcolor = $Color_Button
$Button_Deploy.Add_MouseHover( {$Button_Deploy.backcolor = $Color_ButtonHover})
$Button_Deploy.Add_MouseLeave( {$Button_Deploy.backcolor = $Color_Button})
$Button_Deploy.Add_Click( {Get-CSV4Import})
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
$Button_AddChoco.Add_Click( {Get-InitialVariables})
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
$Button_AddWinget.Add_Click( {Get-InitialVariables})
$objForm.Controls.Add($Button_AddWinget)

# Button "Cancel"
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(100, 300)
$CancelButton.Size = New-Object System.Drawing.Size(100, 25)
$CancelButton.Text = "Cancel"
$CancelButton.Name = "Cancel"
$CancelButton.DialogResult = "Cancel"
$CancelButton.backcolor = $Color_Button
$CancelButton.Add_MouseHover( {$CancelButton.backcolor = $Color_ButtonHover})
$CancelButton.Add_MouseLeave( {$CancelButton.backcolor = $Color_Button})
$CancelButton.Add_Click( {$objForm.Close()})
$objForm.Controls.Add($CancelButton)
# Fenster anzeigen
[void] $objForm.ShowDialog()
