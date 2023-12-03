$ProgramName = "Chocolatey Updater"
$Version = "1"
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $ProgramName }
if($taskExists -and ($taskExists.Description -like "*V$Version*")) {
    Write-Host "Found it!"
}