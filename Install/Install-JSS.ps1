### Name: Install JSS with CLI
### Description: Installs Sitecore JSS along with CLI
### Compatibility: Sifon 0.96

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    [string]$AdminUsername,
    [string]$AdminPassword
)

Function Display-Progress($action, $percent)
{
    Write-Progress -Activity "Installing Sitecore JSS" -CurrentOperation $action -PercentComplete $percent
}

Verify-PortalCredentials -PortalCredentials $PortalCredentials

$package = (Get-Location).Path + "\Downloads\Sitecore JavaScript Services Server for Sitecore 10.0.0 XP 14.0.0 rev. 200714.zip"
If(!(Test-Path -Path $package))
{
    Write-Output "Downloading package from Sitecore Developers Portal..."
    Display-Progress -action "downloading package from Sitecore Developers Portal." -percent 3

    Write-Output "Sifon-MuteProgress"
        Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl "https://dev.sitecore.net/~/media/47F10159903D4D44A3CD66FEBEE6516E.ashx" -TargertFilename $package
    Write-Output "Sifon-UnmuteProgress"
}
else
{
    Write-Output "Found package already downloaded at: $package"
}

If(!(Test-Path -Path $package))
{
    Write-Error "Failed to download the package."
    exit
}

Write-Output "Installing package into Sitecore."
Display-Progress -action "installing package into Sitecore." -percent 31
$InstanceUrl= InstanceUrl -Webroot $Webroot
Install-SitecorePackage -InstanceUrl $InstanceUrl -Username $AdminUsername -Password $AdminPassword -Package $package

Display-Progress -action "installing JSS CLI." -percent 81
Write-Output "Sifon-MuteOutput"
    npm install -g @sitecore-jss/sitecore-jss-cli
Write-Output "Sifon-UnmuteOutput"    


Write-Output "#COLOR:GREEN# Operation complete."
Display-Progress -action "operation complete." -percent 100
