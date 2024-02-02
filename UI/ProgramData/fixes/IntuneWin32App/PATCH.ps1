# Fixing the Add-IntuneWin32AppSupersedence.ps1 script to allow for multiple dependencies
$module = Get-Content "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.2\Public\Add-IntuneWin32AppSupersedence.ps1" 
$module[68] = '                    "relationships" = @()' 
$module[70] = '                if ($Dependencies) { @($Win32AppRelationshipsTable.relationships += $Supersedence; $Win32AppRelationshipsTable.relationships += $Dependencies) } else { @($Win32AppRelationshipsTable.relationships += $Supersedence) }' 
Set-Content "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.2\Public\Add-IntuneWin32AppSupersedence.ps1" $module


$module = Get-Content "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.2\Public\Add-IntuneWin32AppDependency.ps1"
$module[66] = '                    "relationships" = @()'
$module[68] = '                if ($Dependencies) { @($Win32AppRelationshipsTable.relationships += $Supersedence; $Win32AppRelationshipsTable.relationships += $Dependencies) } else { @($Win32AppRelationshipsTable.relationships += $Supersedence) }'
Set-Content "C:\Program Files\WindowsPowerShell\Modules\IntuneWin32App\1.4.2\Public\Add-IntuneWin32AppDependency.ps1" $module

