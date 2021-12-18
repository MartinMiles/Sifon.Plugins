### Name: Install Horizon for Sitecore 10.2
### Description: Installs Sitecore Horizon
### Compatibility: Sifon 1.2.5
### $SelectedFile = new Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker::GetFile("Sitecore license selector","Select Sitecore license in order to install Horizon:","License files|*.xml","OK")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials,
    $SelectedFile
)

$horizon1000URL = "https://sitecoredev.azureedge.net/~/media/7BE931D47A4F4B43887F78F8BA80630E.ashx"
$horizonFilename = "Sitecore Horizon 10.2.0 rev. 05608.zip"
$downloadsFolder = New-Item -ItemType Directory -Path "$((Get-Location).Path)\Downloads" -force
$packageFullPath = "$downloadsFolder\$horizonFilename"

### licence
# Add-Type -Language CSharp @"
# using System;
# namespace Validation 
# {
#     public static class FilePicker
#     {
#         public static string IsSitecoreLicense(string licensePath)
#         {
#             if (licensePath.EndsWith(".xml"))
#             {
#                 return String.Empty;
#             }
#             return "The file provided is not a Sitecore license";
#         }
#     }
# }
# "@;

# $form = new-object Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker
# $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent;

# $form.Caption = "Sitecore license selector";
# $form.Filters = "License files|*.xml";
# $form.Label = "Select Sitecore license in order to install Horizon:";
# $form.Button = "OK";

# # this is the way of passing delegate into DLL without losing types
# $form.Validation = { [Validation.FilePicker]::IsSitecoreLicense($args[0]) }


#$result = $SelectedFile # $form.ShowDialog()

# $licenseMessage = "Sitecore license required for Horizon installation"
# if ($result -ne [System.Windows.Forms.DialogResult]::OK -or [string]::IsNullOrEmpty($form.FilePath))
if ([string]::IsNullOrEmpty($SelectedFile))
{
    Show-Message -Fore "White" -Back "Yellow" -Text "You must provide a valid license in order to install horizon."
    Write-Progress -Activity "Installing Horizon" -CurrentOperation "Complete" -PercentComplete 100
    exit
}

If(!(Test-Path -Path $packageFullPath))
{
    # Verify-PortalCredentials -PortalCredentials $PortalCredentials

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
    Show-Message -Fore "Red" -Back "Yellow" -Text "Failed to download the package."
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

Copy-Item -Path $SelectedFile -Destination $workingFolder

Write-Output "Installing Horizon. This may take quite a while, so please be patient."

#$baseInstallationFolder = split-path -parent $Webroot
# the above commented due to incorrect path level. TODo: investigate the cause of it
$baseInstallationFolder = $Webroot
$horizonFolder = "$baseInstallationFolder\$Prefix.horizon"

"Webroot = $Webroot"
"baseInstallationFolder = $baseInstallationFolder"
"horizonFolder = $horizonFolder"


Write-Output "Sifon-MuteOutput"
    Remove-Item $horizonFolder -Recurse -Force -Confirm:$false
    New-Item -ItemType Directory -Path $horizonFolder -force
Write-Output "Sifon-UnmuteOutput"

Write-Progress -Activity "Installing Horizon" -CurrentOperation "running long batch installation" -PercentComplete 41

$res = [PowerShell]::Create().AddCommand("$workingFolder\InstallHorizon.ps1"). `
    AddParameter("horizonInstanceName", "$Prefix.horizon"). `
    AddParameter("horizonPhysicalPath", $horizonFolder). `
    AddParameter("sitecoreCmInstanceName", $Website). `
    AddParameter("sitecoreCmInstansePath", $Webroot). `
    AddParameter("identityServerPoolName", "$Prefix.identityserver"). `
    AddParameter("identityServerPhysicalPath", "$baseInstallationFolder\$Prefix.identityserver"). `
    AddParameter("licensePath", $SelectedFile). `
    AddParameter("topology", "XP").Invoke() 

Remove-Item $workingFolder -Recurse -Force -Confirm:$false

Write-Progress -Activity "Installing Horizon" -CurrentOperation "Complete" -PercentComplete 100
Show-Message -Fore "Green" -Back "White" -Text "Horizon for Sitecore have been installed."
