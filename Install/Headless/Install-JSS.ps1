### Name: Install JSS with CLI (legacy)
### Description: Installs Sitecore JSS along with CLI
### Compatibility: Sifon 1.0.1
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-JSS.json")

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string[][]]$Urls
)

if($null -eq $Urls){

    Write-Warning "No resources passed for the selected resources"
    exit
}

try{
    npm -v | Out-null
}
catch{
    "."
    Show-Message -Fore "Red" -Back "Yellow" -Text "This script requires NPM for installing CLI which is missing at this machine"
    exit
}

Function Display-Progress($action, $percent)
{
    Write-Progress -Activity "Installing Sitecore JSS" -CurrentOperation $action -PercentComplete $percent
}

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

# Verify-PortalCredentials -PortalCredentials $PortalCredentials

$FileWithoutExtension = $Urls[0][0].Replace(" ","_")
$package = (Get-Location).Path + "\Downloads\$FileWithoutExtension.zip"

If(!(Test-Path -Path $package))
{
    Write-Output "Downloading package from Sitecore Developers Portal..."
    Display-Progress -action "downloading package from Sitecore Developers Portal." -percent 3

    Write-Output "Sifon-MuteProgress"
        Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $Urls[0][1] -TargertFilename $package
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
#Install-SitecorePackageUsingRemoting -InstanceUrl $InstanceUrl -Username $AdminUsername -Password $AdminPassword -Package $package
Install-SitecorePackage -PackageFullPath $package -Webroot $Webroot -Hostbase $InstanceUrl


Display-Progress -action "installing JSS CLI." -percent 81
#Write-Output "Sifon-MuteOutput"
    npm install -g @sitecore-jss/sitecore-jss-cli
#Write-Output "Sifon-UnmuteOutput"    

Show-Message -Fore "Green" -Back "Yellow" -Text "JSS and CLI have been successfully installed"
Display-Progress -action "operation complete." -percent 100
