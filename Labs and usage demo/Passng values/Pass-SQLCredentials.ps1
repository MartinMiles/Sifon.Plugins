### Name: Pass SQL credentials
### Description: Pass SQL credentials
### Compatibility: Sifon 0.99

param(
    [PSCredential]$SqlCredentials
)

$SqlCredentials.GetNetworkCredential().username
$SqlCredentials.GetNetworkCredential().password
