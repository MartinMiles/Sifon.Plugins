### Name: Download code and prepare Sitecore 10
### Description: Downloads and prepares Sitecore 10 for a run in Docker
### Compatibility: Sifon 0.98


param(
    [string]$ProfileName,
    [string]$Repository,
    [string]$Folder,
    [string]$AdminPassword,
    [string]$SaPassword
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

$form = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

$form.Caption = "Sitecore license selector";
$form.Filters = "License files|*.xml";
$form.Label = "Select Sitecore license in order to install Horizon:";
$form.Button = "OK";

# this is the way of passing delegate into DLL without losing types
$form.Validation = { [Validation.FilePicker]::IsSitecoreLicense($args[0]) }
$result = $form.ShowDialog()

$licenseMessage = "Sitecore license required for running in Docker"
if ($result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrEmpty($form.FilePath))
{
    Write-Warning $licenseMessage
    exit
}


#
#
#
#
$ContainersDirectory = New-Item -ItemType Directory -Path Containers -force
$ProfileContainersDirectory = New-Item -ItemType Directory -Path "$ContainersDirectory\$ProfileName" -force

$SourcesDirectory = New-Item -ItemType Directory -Path Cache\Sitecore -force

$BaseDir = (Get-Location).Path
Push-Location

If (!((Test-Path -Path $ContainersDirectory\.env) -and (Test-Path -Path ContainersDirectory\init.ps1)))
{
    Write-Output "Sifon-MuteOutput"
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "getting the code from GitHub repository" -PercentComplete 18
        git clone https://github.com/Sitecore/docker-examples.git "$SourcesDirectory"
        
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "copying the code into a working directory" -PercentComplete 31
        # TODO: validate "$SourcesDirectory\$Folder exists in the cloned code
        Copy-Item "$SourcesDirectory\$Folder\*" -Filter *.* -destination $ProfileContainersDirectory  -Recurse -force

        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "removing temp derectory" -PercentComplete 33
        Remove-Item "$BaseDir\Cache\*" -Recurse -Force -Confirm:$false
    Write-Output "Sifon-UnmuteOutput"
}

cd "$ProfileContainersDirectory"

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "preparing environmental configuration file" -PercentComplete 34


& "$ProfileContainersDirectory\init.ps1" -LicenseXmlPath $form.FilePath -SitecoreAdminPassword $AdminPassword -SqlSaPassword $SaPassword

# $res = [PowerShell]::Create().AddCommand("$ContainersDirectory\init.ps1"). `
#     AddParameter("LicenseXmlPath", $form.FilePath). `
#     AddParameter("SitecoreAdminPassword", $defaultPassword). `
#     AddParameter("SqlSaPassword", $defaultPassword).Invoke() 

Pop-Location

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "Complete" -PercentComplete 100
Write-Output "#COLOR:GREEN# Sitecore in containers has been configured."
