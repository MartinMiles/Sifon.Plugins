### Name: Sitecore package installer
### Description: Installs Sitecore packages via SPE remoting
### Compatibility: Sifon 0.95

param(
	[string]$Webroot,
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b"
)

#
#	1. Inline function passed into LocalFilePickerDialog that validates selected zip file to be actually a Sitecore package
#
Add-Type -ReferencedAssemblies System.IO.Compression,System.IO.Compression.FileSystem -Language CSharp @"
using System;
using System.IO.Compression;
namespace Validation 
{
    public static class FilePicker
    {
        public static string IsSitecorePackage(string zipPath)
        {
            using (ZipArchive archive = ZipFile.OpenRead(zipPath))
            {
                if (archive.Entries.Count == 1 && archive.Entries[0].Name   == "package.zip")
                {
                    return String.Empty;
                }
            }
            return "The file provided is not a Sitecore package";
        }
    }
}
"@;

# Wrapper over progress reporting stream
Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing Sitecore package" -CurrentOperation $action -PercentComplete $percent
}

#
#	2. Reference DLL with LocalFilePickerDialog and pass the parameters, including the above validation 
#
Write-Output "Sifon-MuteOutput"
    [Reflection.Assembly]::LoadFile("$((Get-Location).Path)\Sifon.Shared.dll")
Write-Output "Sifon-UnmuteOutput"



$form = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

$form.Caption = "Sifon Package Installer for Sitecore";
$form.Filters = "Archives|*.zip";
$form.Label = "Pick up the package to install:";
$form.Button = "Install";

# this is the way of passing delegate into DLL without losing types
$form.Validation = { [Validation.FilePicker]::IsSitecorePackage($args[0]) }

$result = $form.ShowDialog()

[string]$PackageFullPath = ""
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $PackageFullPath = $form.FilePath
}

If([string]::IsNullOrEmpty($PackageFullPath))
{
    Write-Warning "You should provide a path to a package to be installed"
    exit
}

$PackageName = Split-Path $PackageFullPath -leaf
Write-Output "Installing package: $PackageName ..."
Display-Progress -action "Installing package: $PackageName ..." -percent 13


$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
Install-SitecorePackage -InstanceUrl $InstanceUrl -Username $AdminUsername -Password $AdminPassword -Package $PackageFullPath

Display-Progress -action " Package installation complete" -percent 100
Write-Output "#COLOR:GREEN# Package installation complete"


