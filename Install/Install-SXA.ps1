### Name: Sitecore SXA installer
### Description: Installs Sitecore packages including remote profiles (copes local package to remote and installs there)
### Compatibility: Sifon 1.00
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-SXA.json")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials,
    $Urls
)

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing Sitecore package" -CurrentOperation $action -PercentComplete $percent
}

# [string]$PackageFullPath = $SelectedFile
# If([string]::IsNullOrEmpty($PackageFullPath))
# {
#     Write-Warning "You should provide a path to a package to be installed"
#     exit
# }

$Urls