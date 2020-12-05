### Name: Add Unicorn icon to Launchpad
### Description: Adds nice looking icon taking to Unicorn control panel, visible to admin users only
### Compatibility: Sifon 1.0.1


param([string]$Webroot)

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

Show-Progress -Activity "Unicorn icon for Sitecore LaunchPad" -Status "downloading the package" -Percent 14

$filename = (Get-Location).Path + "\Downloads\Sitecore.Improvements.LaunchPad.Unicorn-1.1.zip"
$remotingResource = 'https://github.com/MartinMiles/Sitecore.Improvements/raw/master/.SitecorePackages/LaunchPad/Sitecore.Improvements.LaunchPad.Unicorn-1.1.zip'

Invoke-WebRequest -OutFile $filename $remotingResource
if(!(Test-Path -Path $filename)){
    Show-Message -Fore Red -Back Yellow -text "Failed to download the package."
    exit
}

Show-Progress -Activity "Unicorn icon for Sitecore LaunchPad" -Status "installing the package" -Percent 41

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
Install-SitecorePackage -PackageFullPath $filename -Webroot $Webroot -Hostbase $InstanceUrl

Show-Progress -Activity "Unicorn icon for Sitecore LaunchPad" -Status "completed successfully." -Percent 100
Show-Message -Fore Green -Back Yellow -text "installation completed successfully"