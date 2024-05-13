### Name: Add ShowConfig icon to LaunchPad
### Description: Adds nice looking icon taking to ShowConfig.aspx, visible to admin users only
### Compatibility: Sifon 1.0.1

param([string]$Webroot)

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "downloading the package" -Percent 14

$SitecoreVersion =  Get-SitecoreVersion -Webroot $Webroot

$major = [int]$SitecoreVersion.major
$minor = [int]$SitecoreVersion.minor
$version = $(if ($major -gt 10 -or ($major -eq 10 -and $minor -ge 1)) {"2.0"} else {"1.1"})

$archiveName = "Sitecore.Improvements.LaunchPad.ShowConfig-$version.zip"
$filename = (Get-Location).Path + "\Downloads\$archiveName"
$remotingResource = "https://github.com/MartinMiles/Sitecore.Improvements/raw/master/.SitecorePackages/LaunchPad/$archiveName"

Invoke-WebRequest -OutFile $filename $remotingResource
if(!(Test-Path -Path $filename)){
    Show-Message -Fore Red -Back Yellow -text "Failed to download the package."
    exit
}

Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "installing the package" -Percent 41

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot

if($InstanceUrl){

    Install-SitecorePackage -PackageFullPath $filename -Webroot $Webroot -Hostbase $InstanceUrl
    "."
    Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "completed successfully." -Percent 100
    Show-Message -Fore White -Back Yellow -text "Installation completed successfully"
}
else{
    Show-Message -Fore Red -Back Yellow -text "Installation failed: unable to retrieve instance URL hostbase from current profile."
    Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "failed." -Percent 100
}

