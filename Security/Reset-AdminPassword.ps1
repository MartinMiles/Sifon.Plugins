### Name: Reset Sitecore admin password
### Description: This script resets currect 'admin' user's password to a broadly known 'b'
### Compatibility: Sifon 0.99

param(
    [string]$Prefix,
    [string]$ServerInstance,
    [PSCredential]$SqlCredentials
)

$pwd = "qOvF8m8F2IcWMvfOBjJYHmfLABc="

$PasswordResetQuery = "use ${Prefix}_Core; UPDATE [aspnet_Membership] SET Password='$pwd' WHERE UserId IN (SELECT UserId FROM [aspnet_Users] WHERE UserName = 'sitecore\Admin'); SELECT COUNT (*) FROM [aspnet_Membership] WHERE Password='$pwd'"
$output = Invoke-Sqlcmd -Hostname $ServerInstance -Credential $SqlCredentials -Query $PasswordResetQuery

if($output.Item("Column1") -eq "1"){
    Write-Output "_"
    Write-Warning "========================================"
    Write-Output " Password has been successfully changed "
    Write-Warning "========================================"
    Write-Output "_"
    Write-Output "You may now log into Sitecore as 'admin'/'b'."
}
else{
    Write-Warning "====================================================="
    Write-Error "Something went wrong and password hasn't been changed"
    Write-Warning "====================================================="
}
