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

[string]$PackageFullPath = ""

$form = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

$form.Caption = "Sifon Package Installer for Sitecore";
$form.Filters = "Archives|*.zip";
$form.Label = "Pick up the package to install:";
$form.Button = "Install";

# this is the way of passing delegate into DLL without losing types
$form.Validation = { [Validation.FilePicker]::IsSitecorePackage($args[0]) }

$result = $form.ShowDialog()

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
Display-Progress -action "Installing package: $PackageName ..." -percent 3

#
#   3. Retrieve local sites to find where to install package
#
Import-Module WebAdministration
$sites = Get-ChildItem -Path IIS:\Sites

$dict = New-Object 'System.Collections.Generic.List[String[]]'
Foreach ($site in $sites)
{
    $path = $site.PhysicalPath.ToString()

    if($Webroot.TrimEnd('\') -eq $path)
    {
		$bindings = [PowerShell]::Create().AddCommand("Get-WebBinding"). `
                AddParameter("Name", $site.Name).Invoke()
                
		$bindings | ForEach-Object {
			[string[]]$arr = $_.protocol,$_.bindingInformation.Split(':')[2]
			$dict.Add($arr)
		}
    }
}


#
#	4. Install the package using SPE Remoting to the first site
#

If($dict.Count -gt 0)
{
    [string]$Url = $dict[0][0] + "://" + $dict[0][1]
    [string]$PackageToInstall = "$Webroot\App_Data\packages\$PackageName"
    
    Display-Progress -action "Copying the package into instalation directory" -percent 5

    copy $PackageFullPath $PackageToInstall
    Write-Output "Package copied to: $PackageToInstall"
    
    #Set-ExecutionPolicy RemoteSigned
    Import-Module -Name SPE
    
    
    Write-Output "Creating a remote SPE session ..."
    $session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $Url
    
    Display-Progress -action "Sending SPE remote call to: $Url" -percent 15
    Write-Output "Sending SPE remote call to: $Url"

    Invoke-RemoteScript -ScriptBlock {
       Install-Package -Path "$($using:PackageToInstall)" -InstallMode Overwrite
    } -Session $session

    Display-Progress -action " Package installation complete" -percent 100
    Write-Output "#COLOR:GREEN# Package installation complete"
}

