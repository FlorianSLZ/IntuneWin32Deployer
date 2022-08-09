$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Key_Teams = "TaskbarMn"
$Key_Widgets = "TaskbarDn"
if(($(Get-ItemPropertyValue -Path $Path -Name $Key_Teams) -eq 0) -and ($(Get-ItemPropertyValue -Path $Path -Name $Key_Widgets) -eq 0)){exit 0}else{exit 1} # exit 1 = detectet, remediation needed
