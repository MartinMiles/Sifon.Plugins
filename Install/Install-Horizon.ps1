### Name: Install Horizon for Sitecore
### Description: Installs Sitecore Horizon
### Compatibility: Sifon 1.2.5
### $SelectedFile = new Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker::GetFile("Sitecore license selector","Select Sitecore license in order to install Horizon:","License files|*.xml","OK")
### $Version = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-Horizon.json")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [string]$AdminPassword,
    [PSCredential]$PortalCredentials = $null,
    [string]$SelectedFile,
    [string[][]]$Version,
    [switch]$Debug = $false
)

if($SelectedFile -eq "" -or $Version.Length -eq 0){

    "."
    Show-Message -Fore "Red" -Back "Yellow" -Text "License file or version have not been provided"
    exit
}

if(-not(Test-Path -Path $SelectedFile)){

    "."
    Show-Message -Fore "Red" -Back "Yellow" -Text "License file does not exist at: $SelectedFile"
    exit
}

$horizonURL = $Version[0][1]
$horizonFilename = $Version[0][0]
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
        Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $horizonURL -TargertFilename $packageFullPath
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

$localtion = Get-Location
$workingFolder = "$localtion\Cache\Horizon"
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

$baseInstallationFolder = split-path -parent $Webroot
$horizonFolder = "$baseInstallationFolder\horizon.$Prefix.local"

# the above commented due to incorrect path level. TODo: investigate the cause of it
#$baseInstallationFolder = $Webroot

# "Webroot = $Webroot"
# "baseInstallationFolder = $baseInstallationFolder"
# "horizonFolder = $horizonFolder"

Write-Output "Sifon-MuteOutput"
    Remove-Item $horizonFolder -Recurse -Force -Confirm:$false
    New-Item -ItemType Directory -Path $horizonFolder -force
Write-Output "Sifon-UnmuteOutput"

Write-Progress -Activity "Installing Horizon" -CurrentOperation "running long batch installation" -PercentComplete 41

if($Debug){
    "============================================"
    "$workingFolder\InstallHorizon.ps1"
    "horizonInstanceName="+"horizon.$Prefix.local"
    "horizonPhysicalPath=" + $horizonFolder
    "sitecoreCmInstanceName=" + $Website
    "sitecoreCmInstansePath=" + $Webroot
    "identityServerPoolName="+"identityserver.$Prefix.local"
    "identityServerPhysicalPath="+"$baseInstallationFolder\identityserver.$Prefix.local"
    "licensePath="+$SelectedFile
    "============================================"
}

$res = [PowerShell]::Create().AddCommand("$workingFolder\InstallHorizon.ps1"). `
    AddParameter("horizonInstanceName", "horizon.$Prefix.local"). `
    #AddParameter("horizonPhysicalPath", $horizonFolder). `
    AddParameter("sitecoreCmInstanceName", $Website). `
    #AddParameter("sitecoreCmInstansePath", $Webroot). `
    AddParameter("identityServerPoolName", "identityserver.$Prefix.local"). ` 
    AddParameter("identityServerPhysicalPath", "$baseInstallationFolder\identityserver.$Prefix.local"). `
    AddParameter("sitecoreAdminPassword", "b"). `
    AddParameter("licensePath", $SelectedFile). `
    AddParameter("topology", "XP").Invoke() 

Remove-Item $workingFolder -Recurse -Force -Confirm:$false

Write-Progress -Activity "Installing Horizon" -CurrentOperation "Complete" -PercentComplete 100
Show-Message -Fore "Green" -Back "White" -Text "Horizon for Sitecore have been installed."
