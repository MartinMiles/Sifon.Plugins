### Name: Sitecore package installer
### Description: Installs Sitecore packages including remote profiles (copes local package to remote and installs there)
### Compatibility: Sifon 1.0.1
### $SelectedFile = new Sifon.Shared.Forms.LocalFilePickerDialog.LocalFilePicker::GetFile("Sifon Package Installer for Sitecore","Pick up the package to install:","Archives|*.zip","Install")

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string]$SelectedFile
)

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing Sitecore package" -CurrentOperation $action -PercentComplete $percent
}

[string]$PackageFullPath = $SelectedFile
If([string]::IsNullOrEmpty($PackageFullPath))
{
    "."
    Show-Message -Fore Yellow -Back White -Text  "You should provide a path to a package to be installed"
    exit
}

$PackageName = Split-Path $PackageFullPath -leaf
Display-Progress -action "Installing package: $PackageName ..." -percent 13

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
Install-SitecorePackage -PackageFullPath $PackageFullPath -Webroot $Webroot -Hostbase $InstanceUrl

Display-Progress -action " Package installation complete" -percent 100
Show-Message -Fore "Green" -Back "White" -Text "Package installation complete"



