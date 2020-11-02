### Name: Version selector
### Description: Ask user to select Sitecore version
### Compatibility: Sifon 0.99
### $SelectedVersion = new Sifon.Shared.Forms.VersionSelectorDialog.VersionSelector::GetVersion("$Webroot\bin\Sitecore.Kernel.dll", "Sitecore version selector", "Please select Sitecore version:", "OK", $Profile)

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials,
    $SelectedVersion
)

if($SelectedVersion -ne $null){
    $SelectedVersion.Product
}
