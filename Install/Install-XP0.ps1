### Name: Sitecore XP0 Installer
### Description: Downloads and installs any verison for the XP0 topology
### Compatibility: Sifon 1.2.4
### $Params = new Sifon.Shared.Forms.InstallerDialog.Installer::Install()

param(
    [string]$Webroot,
    $UseDownloadCDN,
    $Params
)

$Params.DownloadFile
$Url = "https://sitecoredev.azureedge.net/~/media/" + $Params.DownloadHash + ".ashx"

$Params.RemotingEnabled
$Params.RemotingHost
$Params.RemotingUsername
$Params.RemotingPassword

$Params.SitePhysicalRoot
$Params.LicenseFile
$Params.SitecoreAdminPassword

$Params.SqlServer
$Params.SqlAdminUser
$Params.SqlAdminPassword

$Params.Prefix
$Params.SitecoreSiteName
$Params.XConnectSiteName
$Params.IdentityServerSiteName

$Params.SolrUrl
$Params.SolrService
$Params.SolrRoot

"InstallPrerequisites = $($Params.InstallPrerequisites)"
"CreateProfile = $($Params.CreateProfile)"
"."

# todo copy license to destination (on remote)

[string]$FullPath = (Get-Location).Path + "\Downloads\" + $Params.DownloadFile
if(!(Test-Path -Path $FullPath))
{
    Show-Progress -Percent 10  -Activity "Downloading $($Params.DownloadFile) ..."  -Status "Downloading Sitecore"
    Write-Output "Sifon-MuteProgress"
        Invoke-WebRequest -Uri $Url -OutFile $FullPath
    Write-Output "Sifon-UnmuteProgress"
}
else
{
    "Found file: $FullPath"
}

$folder = (Get-Location).Path + "\Downloads\Install"
Write-Output "Sifon-MuteErrors"
    if(Test-Path -Path $folder)
    {
        Remove-Item -LiteralPath $folder -Force -Recurse | Out-Null # move to the end
    }
Write-Output "Sifon-UnmuteErrors"

New-Item -ItemType Directory -Force -Path $folder | Out-Null
Show-Progress -Percent 15  -Activity "Extracting $($Params.DownloadFile) ..."  -Status "Extracting Sitecore"
Write-Output "Sifon-MuteProgress"
    Expand-Archive -Path $FullPath -DestinationPath $folder
    # "Expanding [$folder\$($Params.DownloadFile)]"
    $conf = Get-ChildItem -Path $folder -Filter "XP0 Configuration files*.zip"
    "== $folder\$conf =="
    Expand-Archive -Path "$folder\$conf" -DestinationPath $folder
Write-Output "Sifon-UnmuteProgress"

$script = "$folder\XP0-SingleDeveloper.ps1"
$content = Get-Content -Raw $script -Encoding UTF8
$content = $content -replace 'Prefix = "XP0"',"Prefix = ""$($Params.Prefix)"""
$content = $content -replace 'SitecoreAdminPassword = ""',"SitecoreAdminPassword = ""$($Params.SitecoreAdminPassword)"""
$content = $content -replace 'SCInstallRoot = "C:\\ResourceFiles"',"SCInstallRoot = ""$folder"""
$content = $content -replace 'SitePhysicalRoot = ""',"SitePhysicalRoot = ""$($Params.SitePhysicalRoot)"""

$content = $content -replace 'XConnectSiteName = "\$prefix.xconnect"',"XConnectSiteName = ""$($Params.XConnectSiteName)"""
$content = $content -replace 'SitecoreSiteName = "\$prefix.sc"',"SitecoreSiteName = ""$($Params.SitecoreSiteName)"""
$content = $content -replace 'IdentityServerSiteName = "\$prefix.IdentityServerSiteName"',"SitePhysicalRoot = ""$($Params.IdentityServerSiteName)"""

$content = $content -replace 'LicenseFile = "\$SCInstallRoot\\license\.xml"',"LicenseFile = ""$($Params.LicenseFile)"""

$content = $content -replace 'SolrUrl = "https://localhost:8983/solr"',"SolrUrl = ""$($Params.SolrUrl)"""
$content = $content -replace 'SolrRoot = "C:\\Solr-8\.4\.0"',"SolrRoot = ""$($Params.SolrRoot)"""
$content = $content -replace 'SolrService = "Solr-8\.4\.0"',"SolrService = ""$($Params.SolrService)"""

$content = $content -replace 'SqlServer = "localhost"',"SqlServer = ""$($Params.SqlServer)"""
$content = $content -replace 'SqlAdminUser = "sa"',"SqlAdminUser = ""$($Params.SqlAdminUser)"""
$content = $content -replace 'SqlAdminPassword = "12345"',"SqlAdminPassword = ""$($Params.SqlAdminPassword)"""

$content | Out-File $script

if($Params.InstallPrerequisites)
{
    Install-SitecoreConfiguration -Path "$folder\prerequisites.json"
}

` XP0-SingleDeveloper.ps1

Show-Progress -Percent 100  -Activity "Done"  -Status "Done"

