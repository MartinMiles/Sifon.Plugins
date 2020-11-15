### Name: Sitecore SXA installer
### Description: Installs Sitecore packages including remote profiles (copes local package to remote and installs there)
### Compatibility: Sifon 1.01
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-SXA.json")

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    [string[][]]$Urls
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

if($null -eq $Urls){

    Write-Warning "No resources passed for the selected resources"
    exit
}


$CurrentProgress = 10;

ForEach ($Url in $Urls) 
{
    $found = $Url[1] -match '\/([0-9a-fA-F]+)\.ashx'
    if ($found) 
    {
        $fileName = $Url[0].Replace(" ", "_") + ".zip"
        $downloadsFolder = New-Item -ItemType Directory -Path  "$((Get-Location).Path)\Downloads" -force
        $packageFullPath = "$downloadsFolder\$fileName"

        VerifyOrDownload-File -moduleName $fileName -moduleResourceUrl $Url[1] -progress $CurrentProgress
        
        $CurrentProgress += 20
        Display-Progress -action "installing the downloaded module" -percent $CurrentProgress

        $InstanceUrl = Get-InstanceUrl -Webroot $Webroot
        Install-SitecorePackage -PackageFullPath $PackageFullPath -Webroot $Webroot -Hostbase $InstanceUrl
        $CurrentProgress+=20
    }    
}

Display-Progress -action "done." -percent 100
