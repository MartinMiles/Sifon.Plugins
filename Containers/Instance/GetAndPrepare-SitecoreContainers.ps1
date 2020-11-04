### Name: Download code and prepare Sitecore 10
### Description: Downloads and prepares Sitecore 10 for a run in Docker
### Compatibility: Sifon 1.00
### Local-only

param(
    [string]$ContainerProfileName,
    [string]$Repository,
    [string]$Folder,
    [string]$SitecoreAdminPassword,
    [string]$SaPassword,
    [string]$InitParams
)

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "Requesting Sitecore license file" -PercentComplete 4

### get licence
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

$licenseSelector = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
$licenseSelector.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

$licenseSelector.Caption = "Sitecore license selector";
$licenseSelector.Filters = "License files|*.xml";
$licenseSelector.Label = "Select Sitecore license in order to run Sitecore in containers:";
$licenseSelector.Button = "OK";

# this is the way of passing delegate into DLL without losing types
$licenseSelector.Validation = { [Validation.FilePicker]::IsSitecoreLicense($args[0]) }
$result = $licenseSelector.ShowDialog()

$licenseMessage = "Sitecore license required for running in Docker"
if ($result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrEmpty($licenseSelector.FilePath))
{
    Write-Warning $licenseMessage
    exit
}

# licenseSelector should be used as the parameter passed into Init.ps1
[string]$licensePath = $licenseSelector.FilePath


#
#
$ContainersDirectory = New-Item -ItemType Directory -Path Containers -force
$ProfileContainersDirectory = New-Item -ItemType Directory -Path "$ContainersDirectory\$ContainerProfileName" -force

$SourcesDirectory = New-Item -ItemType Directory -Path Cache\Sitecore -force

$BaseDir = (Get-Location).Path
Push-Location

If (!((Test-Path -Path $ContainersDirectory\.env) -and (Test-Path -Path ContainersDirectory\init.ps1)))
{
    Write-Output "Sifon-MuteOutput"
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "getting the code from GitHub repository" -PercentComplete 18
	git clone $Repository "$SourcesDirectory"
        
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "copying the code into a working directory" -PercentComplete 31
        # TODO: validate "$SourcesDirectory\$Folder exists in the cloned code
        Copy-Item "$SourcesDirectory\$Folder\*" -Filter *.* -destination $ProfileContainersDirectory  -Recurse -force

        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "removing temp derectory" -PercentComplete 33
        Remove-Item "$BaseDir\Cache\*" -Recurse -Force -Confirm:$false
    Write-Output "Sifon-UnmuteOutput"
}

Set-Location -Path $ProfileContainersDirectory

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "preparing environmental configuration file" -PercentComplete 34

$file = [IO.Path]::Combine($ProfileContainersDirectory, 'init.ps1')
$regex = '(Install-Module\s*SitecoreDockerTools.*)'
(Get-Content $file) -replace $regex, '$1 -allowClobber -force' | Set-Content $file

$file  = $file -replace ' ', '` '
try{
	Invoke-Expression "$file $InitParams"
	Write-Output "#COLOR:GREEN# Sitecore in containers has been configured."

}
catch{
	Write-Output "#COLOR:RED# Something went wron while running initialization script."
}

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "Complete" -PercentComplete 100
Pop-Location

