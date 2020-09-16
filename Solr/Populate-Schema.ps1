### Name: Populates Managed Schema
### Description: Populates Managed Schema for a specifix index or all of them
### Compatibility: Sifon 0.95, SIF

param(
    [string]$IndexName = "sitecore_master_index",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b"
)

$params = @{
    Path            = $MyInvocation.MyCommand.Definition.Replace(".ps1", ".json")
    Hostname        = "https://platform"
    IndexName       = $IndexName
    AdminUsername   = $AdminUsername
    AdminPassword   = "$AdminPassword"
}

Install-SitecoreConfiguration  @params