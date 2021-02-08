### Name: Install package by URL
### Description: Downloads and installs a Sitecore packages from its URL (for example from dev.sitecore.net or GitHub)
### Compatibility: Sifon 1.2.4
### $Url = new Sifon.Shared.Forms.UrlPickerDialog.UrlPicker::GetUrl("Sifon Package Downloader and Installer","Please select a downloadable URL for a package zip file:","Download", $true, $false)

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [System.Uri]$Url
)

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing Sitecore package" -CurrentOperation $action -PercentComplete $percent
}

$WebRequest = [System.Net.WebRequest]::Create($Url.ToString())
$Response = $WebRequest.GetResponse()

$dispositionHeader = $Response.Headers['Content-Disposition']
try
{
    $disposition = [System.Net.Mime.ContentDisposition]::new($dispositionHeader)
    $FullPath = $disposition.FileName
}
catch 
{
    $FullPath = [System.IO.Path]::GetFileName($Url.LocalPath)
}

$Response.Dispose()

if($FullPath)
{
    New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null
    [string]$PackageFullPath = (Get-Location).Path + "\Downloads\" + $FullPath

    Write-Output "Sifon-MuteProgress"
        Invoke-WebRequest -Uri $Url.ToString() -OutFile $PackageFullPath
    Write-Output "Sifon-UnmuteProgress"

    If(!(Test-Path $PackageFullPath))
    {
        Show-Message -Fore Red -Back White -Text  "Failure while downloading the the package"
        exit
    }
    
    $PackageName = Split-Path $PackageFullPath -leaf
    Display-Progress -action "Installing package: $PackageName ..." -percent 13

    $InstanceUrl = Get-InstanceUrl -Webroot $Webroot
    Install-SitecorePackage -PackageFullPath $PackageFullPath -Webroot $Webroot -Hostbase $InstanceUrl

    Display-Progress -action " Package installation complete" -percent 100
    "."
    Show-Message -Fore "Green" -Back "White" -Text "Package installation complete"
}
else
{
    Show-Message -Fore "Red" -Back "White" -Text "Failed to retrieve package filename"
}
