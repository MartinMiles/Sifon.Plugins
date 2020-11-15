### Name: Pass SQL credentials
### Description: Output decrypted SQL erver credentials
### Compatibility: Sifon 1.01

param(
    [PSCredential]$SqlCredentials
)

Show-Message -Fore "Yellow" -Back "White" -Text "Decrypred SQL Server credentials"

"Username = " + $SqlCredentials.GetNetworkCredential().username
"Password = " + $SqlCredentials.GetNetworkCredential().password
