### Name: A sample Docker script
### Description: Installs Sitecore 10 in Docker
### Compatibility: Sifon 0.98

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "Requesting Sitecore license file" -PercentComplete 4
$defaultPassword = "Password12345"



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

# If (Test-Path Cache\Sitecore)
# {
#     Remove-Item Cache\Sitecore -Recurse -Force -Confirm:$false | Out-Null
# }

$SourcesDirectory = New-Item -ItemType Directory -Path Cache\Sitecore -force

$BaseDir = (Get-Location).Path
Push-Location

If (!((Test-Path -Path $ContainersDirectory\.env) -and (Test-Path -Path ContainersDirectory\init.ps1)))
{
    Write-Output "Sifon-MuteOutput"
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "getting the code from GitHub repository" -PercentComplete 18
        git clone https://github.com/Sitecore/docker-examples.git "$SourcesDirectory"
        
        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "copying the code into a working directory" -PercentComplete 31
        Copy-Item "$SourcesDirectory\getting-started\*" -Filter *.* -destination $ContainersDirectory  -Recurse -force

        Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "removing temp derectory" -PercentComplete 33
        Remove-Item "$BaseDir\Cache\*" -Recurse -Force -Confirm:$false
    Write-Output "Sifon-UnmuteOutput"
}

cd "$ContainersDirectory"

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "preparing environmental configuration file" -PercentComplete 34




& "$ContainersDirectory\init.ps1" -LicenseXmlPath $form.FilePath -SitecoreAdminPassword $defaultPassword -SqlSaPassword $defaultPassword

# $res = [PowerShell]::Create().AddCommand("$ContainersDirectory\init.ps1"). `
#     AddParameter("LicenseXmlPath", $form.FilePath). `
#     AddParameter("SitecoreAdminPassword", $defaultPassword). `
#     AddParameter("SqlSaPassword", $defaultPassword).Invoke() 


Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "starting containers" -PercentComplete 34
$ContainersDirectory
Start-Process powershell -Wait -WorkingDirectory $ContainersDirectory -ArgumentList '-noexit -command "docker-compose up -d"'

#start powershell { cd "$ContainersDirectory"; docker-compose up -d}
#invoke-expression 'cmd /c start powershell -Command { cd "$ContainersDirectory"; docker-compose up -d }'


start https://xp0cm.localhost/sitecore

Pop-Location

Write-Progress -Activity "Run Sitecore in containers" -CurrentOperation "Complete" -PercentComplete 100
Write-Output "#COLOR:GREEN# Sitecore in containers has been configured."
