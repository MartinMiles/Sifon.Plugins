### Name: Install Sitecore PowerShell with Remoting
### Description:  Sitecore PowerShell Extension with Remoting enabled
### Compatibility: Sifon 1.01
### Dependencies: "Install-SitecorePowershellWithRemoting.config"
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-SPE.json")


param(
    [string]$Webroot,
    [string]$Website,
    $PortalCredentials,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string[][]]$Urls
)

if($null -eq $Urls){

    Write-Warning "No resources passed for the selected resources"
    exit
}

$moduleName =  $Urls[1][0]
$moduleFilename = (Get-Location).Path + "\Downloads\" + $moduleName + ".zip"
$moduleResource = $Urls[1][1]
$remotingFilename = (Get-Location).Path + "\Downloads\" + $Urls[0][0] + ".zip"
$remotingResource = $Urls[0][1]
$remotingModuleFolder = "c:\Program Files\WindowsPowerShell\Modules"


$config = $aspxFullpath = $PSCommandPath.Replace('.ps1','.config')

Function Display-Progress($action, $percent){

    Write-Progress -Activity "Installing Sitecore PowerShell Extentions" -CurrentOperation $action -PercentComplete $percent
}

Verify-PortalCredentials -PortalCredentials $PortalCredentials

If(!(Test-Path -Path $moduleFilename))
{
    Write-Output "Downloading package $moduleName from Sitecore Developers Portal..."
    Display-Progress -action "downloading package  $moduleName from Sitecore Developers Portal." -percent 3

    Write-Output "Sifon-MuteProgress"
        Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $moduleResource -TargertFilename $moduleFilename
    Write-Output "Sifon-UnmuteProgress"
}
else
{
    Write-Output "Found package already downloaded at: $moduleFilename"
}

If(!(Test-Path -Path $moduleFilename))
{
    Write-Error "Failed to download the package."
    exit
}


Display-Progress -action "intalling SPE package  $moduleName from Sitecore Developers Portal." -percent 24
$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
Install-SitecorePackage -PackageFullPath $moduleFilename -Webroot $Webroot -Hostbase $InstanceUrl


Display-Progress -action "downloading SPE remoting module from $remotingResource" -percent 57

Invoke-WebRequest -OutFile $remotingFilename $remotingResource
if(!(Test-Path -Path $remotingFilename)){
    Write-Error "Failed to download Sitecore PowerShell Remoting module."
    exit
}

Display-Progress -action "extracting SPE remoting" -percent 61

Write-Output "Sifon-MuteProgress"
    Expand-Archive -Path $remotingFilename -DestinationPath $remotingModuleFolder -Force
Write-Output "Sifon-UnmuteProgress"


Display-Progress -action "copying remoting security config patch into an Include config folder" -percent 74
Copy-Item $config -destination "$Webroot\App_Config\Include\z.Spe" -force

Display-Progress -action "verifying installation by making a remoting request to instance" -percent 77
Write-Output "Finally, verifying installation by making a remoting request to instance ..."
Import-Module SPE
$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
Invoke-RemoteScript -ScriptBlock {
    Get-Item -Path "master:\content\Home" | Out-Null
} -Session $session

$result = "Sitecore PowerShell Extensions module has been successfully installed and Remoting has been enabled for this instance"
Display-Progress -action $result -percent 100
Write-Output "#COLOR:GREEN# $result"