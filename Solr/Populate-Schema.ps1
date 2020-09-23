### Name: Populates Managed Schema
### Description: Populates Managed Schema for a specifix index or all of them
### Compatibility: Sifon 0.95, SIF

param(
    [string]$IndexName = "sitecore_master_index",
    [string]$AdminUsername,
    [string]$AdminPassword
)

[string]$Hostname = Get-InstanceUrl -Webroot $Webroot

$params = @{
    Path            = $MyInvocation.MyCommand.Definition.Replace(".ps1", ".json")
    Hostname        = $Hostname
    IndexName       = $IndexName
    AdminUsername   = $AdminUsername
    AdminPassword   = "$AdminPassword"
}

Install-SitecoreConfiguration  @params