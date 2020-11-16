### Name: Populates Managed Schema
### Description: Populates Managed Schema for a specifix index or all of them
### Compatibility: Sifon 1.01
### Dependencies: "Populate-Schema.json"

param(
    [string]$Webroot,
    [string]$IndexName = "sitecore_master_index",
    [string]$AdminUsername,
    [string]$AdminPassword,
    $SelectedFile
)

[string]$Hostname = Get-InstanceUrl -Webroot $Webroot

$path = $MyInvocation.MyCommand.Definition.Replace(".ps1", ".json")

$params = @{
    Path            = $path 
    Hostname        = $Hostname
    IndexName       = $IndexName
    AdminUsername   = $AdminUsername
    AdminPassword   = $AdminPassword
}

Write-Output "Populating managed schema for index: $IndexName ..."
Write-Output "Sifon-MuteOutput"
    Install-SitecoreConfiguration  @params
Write-Output "Sifon-UnmuteOutput"

Show-Message -Fore Green -Back White -Text "Operation complete."