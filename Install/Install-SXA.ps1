### Name: Sitecore SXA installer
### Description: Installs Sitecore packages including remote profiles (copes local package to remote and installs there)
### Compatibility: Sifon 1.00
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-SXA.json")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [PSCredential]$PortalCredentials,
    $Urls
)

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing SXA packages" -CurrentOperation $action -PercentComplete $percent
}

Function VerifyOrDownload-File($moduleName, $moduleResourceUrl, $progress)
{
    $fullPath = (Get-Location).Path + "\Downloads\$moduleName"


    If(!(Test-Path -Path $fullPath))
    {
        Verify-PortalCredentials -PortalCredentials $PortalCredentials

        Write-Output "Downloading $moduleName package from Sitecore Developers Portal..."
        Display-Progress -action "downloading $moduleName package from Sitecore Developers Portal." -percent $progress
    
        Write-Output "Sifon-MuteProgress"
            Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $moduleResourceUrl -TargertFilename $fullPath
        Write-Output "Sifon-UnmuteProgress"
    }
    else
    {
        Write-Output "Found package $moduleName already downloaded within Downloads folder."
    }
}

if($unll -eq $Urls){

    Write-Warning "No resources passed for the selected resources"
    exit
}

$found = $string -match '\/([0-9a-fA-F]+)\.ashx'

ForEach ($Url in $Urls) 
{
    if ($found) {

        $fileName = $matches[1] + ".zip"
        $downloadsFolder = New-Item -ItemType Directory -Path  "$((Get-Location).Path)\Downloads" -force
        $packageFullPath = "$downloadsFolder\$fileName"

        VerifyOrDownload-File -moduleName $fileName -moduleResourceUrl $Url -progress 3

        $InstanceUrl = Get-InstanceUrl -Webroot $Webroot
        Install-SitecorePackage -PackageFullPath $PackageFullPath -Webroot $Webroot -Hostbase $InstanceUrl
        
        VerifyOrDownload-File -moduleName $fileName -moduleResourceUrl $Url -progress 30
    }
}

Display-Progress -action "done." -percent 100

