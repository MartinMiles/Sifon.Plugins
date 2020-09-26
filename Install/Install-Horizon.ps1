### Name: Install Horizon for Sitecore 10.0
### Description: Installs Sitecore JSS along with CLI
### Compatibility: Sifon 0.96

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials
)

$horizon1000URL = "https://dev.sitecore.net/~/media/6428CB6CC4F143E9A085AF2C36706E26.ashx"
$horizonFilename = "Sitecore Horizon 10.0.0.zip"
$packageFullPath = (Get-Location).Path + "\Downloads\$horizonFilename"


### licence
Add-Type -Language CSharp @"
using System;
namespace Validation 
{
    public static class FilePicker
    {
        public static string IsSitecoreLicense(string licensePath)
        {
            if (licensePath.EndsWith(".xml"))
            {
                return String.Empty;
            }
            return "The file provided is not a Sitecore license";
        }
    }
}
"@;

$form = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

$form.Caption = "Sitecore license selector";
$form.Filters = "License files|*.xml";
$form.Label = "Select Sitecore license in order to install Horizon:";
$form.Button = "OK";

# this is the way of passing delegate into DLL without losing types
$form.Validation = { [Validation.FilePicker]::IsSitecoreLicense($args[0]) }

$result = $form.ShowDialog()

$licenseMessage = "Sitecore license required for Horizon installation"
if ($result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrEmpty($form.FilePath))
{
    Write-Warning $licenseMessage
    exit
}

If(!(Test-Path -Path $packageFullPath))
{
    Verify-PortalCredentials -PortalCredentials $PortalCredentials

    Write-Output "Downloading package $horizonFilename from Sitecore Developers Portal..."

    Write-Output "Sifon-MuteProgress"
        Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $horizon1000URL -TargertFilename $packageFullPath
    Write-Output "Sifon-UnmuteProgress"
}
else
{
    Write-Output "Found package already downloaded at: $packageFullPath"
}

If(!(Test-Path -Path $packageFullPath))
{
    Write-Error "Failed to download the package."
    exit
}


$workingFolder = "c:\Sifon\Cache\Horizon"
Write-Output "Sifon-MuteErrors"
Write-Output "Sifon-MuteOutput"
    Remove-Item $workingFolder -Recurse -Force -Confirm:$false
    New-Item -ItemType Directory -Path $workingFolder -force
Write-Output "Sifon-UnmuteOutput"
Write-Output "Sifon-UnmuteErrors"
Write-Output "Sifon-MuteProgress"
    Expand-Archive -Path $packageFullPath -DestinationPath $workingFolder
Write-Output "Sifon-UnmuteProgress"



if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    Copy-Item -Path $form.FilePath -Destination $workingFolder
}
else {
    Write-Warning "You must provide a valid license in order to install horizon."
    Write-Progress -Activity "Installing Horizon" -CurrentOperation "Complete" -PercentComplete 100
    exit
}


Write-Output "Installing package into Sitecore."

$baseInstallationFolder = split-path -parent $Webroot
$horizonFolder = "$baseInstallationFolder\$Prefix.horizon"
Write-Output "Sifon-MuteOutput"
    Remove-Item $horizonFolder -Recurse -Force -Confirm:$false
    New-Item -ItemType Directory -Path $horizonFolder -force
Write-Output "Sifon-UnmuteOutput"

Write-Output "Sifon-MuteProgress"
& "$workingFolder\InstallHorizon.ps1" -horizonInstanceName "$Prefix.horizon" -horizonPhysicalPath $horizonFolder -sitecoreCmInstanceName $Website -sitecoreCmInstansePath $Webroot -identityServerPoolName "$Prefix.identityserver" -identityServerPhysicalPath "$baseInstallationFolder\$Prefix.identityserver" -licensePath $form.FilePath -topology "XP"
Write-Output "Sifon-UnmuteProgress"

Remove-Item $workingFolder -Recurse -Force -Confirm:$false

Write-Progress -Activity "Installing Horizon" -CurrentOperation "Complete" -PercentComplete 100
Write-Output "#COLOR:GREEN# Horizon for Sitecore have been installed."
