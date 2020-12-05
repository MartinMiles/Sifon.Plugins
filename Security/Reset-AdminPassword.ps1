### Name: Reset Sitecore admin password
### Description: This script resets currect 'admin' user's password to a broadly known 'b'
### Compatibility: Sifon 1.0.1

param(
    [string]$Prefix,
    [string]$ServerInstance,
    [PSCredential]$SqlCredentials
)

$pwd = "qOvF8m8F2IcWMvfOBjJYHmfLABc="
$salt = 'OM5gu45RQuJ76itRvkSPFw=='

$PasswordResetQuery = "use ${Prefix}_Core; UPDATE aspnet_Membership SET Password='$pwd', PasswordSalt='$salt', IsLockedOut = 0, FailedPasswordAttemptCount = 0 WHERE UserId IN (SELECT UserId FROM aspnet_Users WHERE UserName = 'sitecore\Admin'); SELECT COUNT (*) FROM [aspnet_Membership] WHERE Password='$pwd'"

$output = Invoke-Sqlcmd -Hostname $ServerInstance -Credential $SqlCredentials -Query $PasswordResetQuery

if($output.Item("Column1") -eq "1"){
    Write-Output "."
    Show-Message -Fore "Green" -Back "Yellow" -Text "Sintecore instance password has been successfully changed"
    Write-Output "."
    Write-Output "You may now log into Sitecore as 'admin'/'b'."
}
else{
    Show-Message -Fore Red -Back Yellow -Text "Something went wrong and password hasn't been changed "
}
