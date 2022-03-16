### Name: Show profile values
### Description: Demostrates how you can pass a single profile into a script a consume its values
### Compatibility: Sifon 1.0.1

param($Profile)

 $SitecoreVersion = Get-SitecoreVersion -Webroot $Profile.Webroot -ToString

Write-Output "."
Show-Message -Fore "Yellow" -Back "White" -Text @("Sitecore platform version: $SitecoreVersion","Parameters passed into this script with `$Profile and their values")
Write-Output "."

$Profile.PSObject.Properties | % {$_.Name + " = " + $_.Value}