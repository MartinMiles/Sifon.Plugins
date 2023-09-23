### Name: Desktop
### Description: Load Sitecore CM from a selected profile
### Compatibility: Sifon 1.3.5

param(
    [string]$Webroot,
    [string]$WebrootCD=$null, #'c:\inetpub\wwwroot\cd.xm.local',
    [string]$Website,
    [string]$WebsiteCD=$null, #='cd.xm.local',
    [string]$Prefix,
    $Profile
)

$hostname = $Profile.CDSiteName
$SitecoreVersion = Get-SitecoreVersion -Webroot $Profile.Webroot -ToString
$topology = if ($Profile.IsXM) { "XM" } else { "XP" }

Write-Output "."
Show-Message -Fore "Yellow" -Back "White" -Text @("Sitecore $topology platform version: $SitecoreVersion")
Write-Output "."
"Opening CM website at: https://$hostname/sitecore"

Start-Process "https://$Website/sitecore/shell/default.aspx"


