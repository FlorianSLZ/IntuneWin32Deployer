function Add-IWDAppGroup{
    
    <#
    .SYNOPSIS
        Create and assign an Azure AD group for application assignment.

    .DESCRIPTION
        This function creates an Azure AD group for the assignment of a specified application. 
        It then assigns the application to the group using Microsoft Intune.

    .PARAMETER Program
        An array containing information about the application to be assigned to the group.

    .EXAMPLE
        Example 1:
        Add-IWDAppGroup -Program @{"id"="App123";"manager"="ManagerName";"Name"="ApplicationName"}

        This command creates an Azure AD group and assigns the specified application to the group.

    .NOTES
        Author: Florian Salzmann (@FlorianSLZ)
        Version: 1.0
        Date: 2023-10-15

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "An array containing information about the application to be assigned to the group.")]
        [ValidateNotNullOrEmpty()]
        [array]$Program
    )
    
    try{
        
        # Connect AAD if not connected
        $MGSession = Connect-MgGraph -Scopes $global:scopes
        Write-Verbose $MGSession

        # Create Group
        $grpname = "$($global:SettingsVAR.AADgrpPrefix )$($Program.id)"
        if(!$(Get-MgGroup -Filter "DisplayName eq '$grpname'")){
            Write-Host "  Create AAD group for assigment:  $grpname" -Foregroundcolor cyan
            $GrpObj = New-MgGroup -DisplayName "$grpname" -Description "App assigment: $($Program.id) $($Program.manager)" -MailEnabled:$False  -MailNickName $grpname -SecurityEnabled
        }else{$GrpObj = Get-MgGroup -Filter "DisplayName eq '$grpname'"}

        # Add App Assigment
        Write-Host "  Assign Group *$grpname*  to  *$($Program.Name)*" -Foregroundcolor cyan
        $Session = Connect-MSIntuneGraph -TenantID $SettingsVAR.Tenant
        Write-Verbose $Session
        
        $Win32App = Get-IntuneWin32App -DisplayName "$($Program.Name)"
        Add-IntuneWin32AppAssignmentGroup -Include -ID $Win32App.id -GroupID $GrpObj.id -Intent "required" -Notification "showAll"
        
        
    }catch{
        Write-Error "Error while processing $PropertyName1 `n$_"
    }

}
