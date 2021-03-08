### Name: Update License File
### Description: Update license file for selected instance (Sitecore site, XConnect, Identity, Horizon)
### Compatibility: Sifon 1.0.1
### $SelectedFile = new Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker::GetFile("Sitecore license selector","Select Sitecore license in order to install Horizon:","License files|*.xml","OK")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials,
    $SelectedFile
)

if ([string]::IsNullOrEmpty($SelectedFile))
{
    Show-Message -Fore "White" -Back "Yellow" -Text "You must provide a valid license in order to install horizon."
    Write-Progress -Activity "Updating license" -CurrentOperation "Complete" -PercentComplete 100
    exit
}

try
{
    "."
    Show-Message -Fore yellow -Back white -Text "Replacing Sitecore license(s) for $Website instance"
    "."

    $XConnect = Get-SiteFolder -name $Website -type 'XConnect'
    $IdentityServer = Get-SiteFolder -name $Website -type 'IdentityServer'
    $Horizon = Get-SiteFolder -name $Website -type 'Horizon'

    $scLicense = "$Webroot\App_Data\license.xml"
    Copy-Item $SelectedFile $scLicense -force | Out-Null
    "Successfully replaced license for Sitecore at: $scLicense"
    "."

    $xcLicense = "$XConnect\App_Data\license.xml"
    if(($null -ne $XConnect) -and (Test-Path $xcLicense))
    {
        Copy-Item $SelectedFile $xcLicense -force | Out-Null
        "Successfully replaced license for XConnect at: $xcLicense"
        "."
    }

    $isLicense = "$IdentityServer\sitecoreruntime\license.xml"
    if(($null -ne $IdentityServer) -and (Test-Path $isLicense))
    {
        Copy-Item $SelectedFile $isLicense -force | Out-Null
        "Successfully replaced license for Identity Server at: $isLicense"
        "."
    }

    $hoLicense = "$Horizon\sitecoreruntime\license.xml"
    if(($null -ne $Horizon) -and (Test-Path $hoLicense))
    {
        Copy-Item $SelectedFile $hoLicense -force | Out-Null
        "Successfully replaced license for Horizon at: $hoLicense"
        "."
    }

    "."
    Write-Progress -Activity "Replacing Sitecore licenses" -CurrentOperation "Complete" -PercentComplete 100
    Show-Message -Fore "LimeGreen" -Back "White" -Text "All Sitecore licenses have been successfully updated"
}
catch
{
    Show-Message -Fore "Red" -Back "Yellow" -Text "Something went wrong, failed to replace all the licenses for $Website instance"
}

