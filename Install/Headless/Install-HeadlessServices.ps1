### Name: Sitecore Headless Rendering
### Description: Installs Sitecore Headless Rendering
### Compatibility: Sifon 1.3.5
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-HeadlessServices.json")

# TODO: Parametrize the above menthod GetFile("$PSScriptRoot\Install-HeadlessServices.json") to accept the filter for TOPOLOGY:
#       ("$PSScriptRoot\Install-HeadlessServices.json", Sitecore Headless Services Server $TOPOLOGY 21.0.583.zip)

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    [string[][]]$Urls,
    $Profile
)

# if($Profile.IsXM){
#     "XM"
# }
# else{
#     "xp"
# }
# exit

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing Headless Rendering package" -CurrentOperation $action -PercentComplete $percent
}

Function VerifyOrDownload-File($moduleName, $moduleResourceUrl, $progress)
{
    $fullPath = (Get-Location).Path + "\Downloads\$moduleName"


    If(!(Test-Path -Path $fullPath))
    {
        # Verify-PortalCredentials -PortalCredentials $PortalCredentials

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

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

$CurrentProgress = 10;

ForEach ($Url in $Urls) 
{
    $found = $Url[1] -match '\/([0-9a-fA-F]+)\.ashx'
    if ($found) 
    {
        $fileName = $Url[0].Replace(" ", "_")
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
Write-Output '.'
Show-Message -Fore Green -Back White -Text "Sitecore Headless Rendering have been installed"
Display-Progress -action "done." -percent 100

