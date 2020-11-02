### Name: Output selected profile parameters
### Description: Outputs container profile variables - shows you all the parameters options to use with containers
### Compatibility: Sifon 0.98

param(
    [string]$ProfileName,
    [string]$Repository,
    [string]$Folder,
    [string]$AdminPassword,
    [string]$SaPassword
)

Write-Output "ProfileName = $ProfileName"
Write-Output "Repository = $Repository"
Write-Output "Folder = $Folder"
Write-Output "AdminPassword = $AdminPassword"
Write-Output "SaPassword = $SaPassword"