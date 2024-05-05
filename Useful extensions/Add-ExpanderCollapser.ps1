### Name: Add Expand and Collapse button to Content Editor
### Description: Expand and Collapse buttons help navigating multiple sections quicker, especially valuable for SXA sites
### Compatibility: Sifon 1.0.1

param([string]$Webroot)

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "downloading the package" -Percent 14

$archiveName = "Expand-Collapse.zip"
$filename = (Get-Location).Path + "\Downloads\$archiveName"
$remotingResource = "https://github.com/MartinMiles/Sitecore.Improvements/raw/master/.SitecorePackages/ExpandCollapse/$archiveName"

Invoke-WebRequest -OutFile $filename $remotingResource
if(!(Test-Path -Path $filename)){
    Show-Message -Fore Red -Back Yellow -text "Failed to download the package."
    exit
}

Show-Progress -Activity "Expand Collapse buttons for Experience Editor" -Status "installing the package" -Percent 41

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot

if($InstanceUrl){

    Install-SitecorePackage -PackageFullPath $filename -Webroot $Webroot -Hostbase $InstanceUrl
    "."
    Show-Progress -Activity "Expand Collapse buttons for Experience Editor" -Status "completed successfully." -Percent 100
    Show-Message -Fore White -Back Yellow -text "Installation completed successfully (you may need to delete browser cache to enforse this feature)"
}
else{
    Show-Message -Fore Red -Back Yellow -text "Installation failed: unable to retrieve instance URL hostbase from current profile."
    Show-Progress -Activity "ShowConfig icon for Sitecore LaunchPad" -Status "failed." -Percent 100
}

