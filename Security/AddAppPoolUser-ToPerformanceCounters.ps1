### Name: Add AppPool user to Performance Counters
### Description: Sitecore needs access to registry keys for performance counters to work
### Compatibility: Sifon 1.0.1

param(
    [string]$Website
)

$accountName = $Website
$group = [ADSI]"WinNT://$Env:ComputerName/Performance Monitor Users,group"

$ntAccount = New-Object System.Security.Principal.NTAccount($accountName)

"."
"Account to add to Performance Monitor Users: '$ntAccount'."

$strSID = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])

#Create the user
$user = [ADSI]"WinNT://$strSID"

try
{
     $group.Add($user.Path)
     "."
     Show-Message -Fore LimeGreen -Back Yellow -Text @("$accountName successfully added as a member of the 'Performance Monitor Users' group"," ","You may need to do iisreset for changes to take effect.")
}
catch
{
     "."
     Show-Message -Fore orange -Back white -Text "'$accountName' is already a member of Performance Monitor Users"
}
