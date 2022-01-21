### Name: Install Publishing Service 6.0.0
### Description: Installs Sitecore Publishing Service
### Compatibility: Sifon 1.2.5
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-PublishingService_6.json")

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [PSCredential]$SqlCredentials,
    [PSCredential]$PortalCredentials,
    [string[][]]$Urls,
    [switch]$Debug = $false
)

if($null -eq $Urls){

    "."
    Show-Message -Fore "Red" -Back "Yellow" -Text "No resources passed for the selected resources"
    exit
}


if(-not (Verify-NetCoreHosting -MinimumVersion "3.1.17")){

        $ErrorMessage  = @(
            "Installation terminated!",
            "",
            "",
            "Sitecore Publishing Service 6.* requires .NET core hosting bundle version 3.1.17 or higher"
            "",
            "Please select and right-click the link below to download it in a browser and then install.",
            "(it is located under 'ASP.NET Core Runtime' section, named as Hosting Bundle (for Windows).",
            "",
            "https://dotnet.microsoft.com/en-us/download/dotnet/3.1"
            );
    "."
    Show-Message -Fore white -Back yellow -Text $ErrorMessage
    exit    
}

$moduleName = $Urls[1][0].Replace(" ", "_") + ".zip"
$serviceName = $Urls[0][0].Replace(" ", "_") + ".zip"
$downloadsFolder = New-Item -ItemType Directory -Path  "$((Get-Location).Path)\Downloads" -force
$moduleFilename = "$downloadsFolder\$moduleName"
$serviceFilename = "$downloadsFolder\$serviceName"

Function Replace-WithDatabaseAdmin($ConnectionString, $Username, $Password)
{
    $ConnectionString = $ConnectionString -replace "User ID=(\w+);", "User ID=$Username;"
    $ConnectionString = $ConnectionString -replace "Password=(\w+)", "Password=$Password"
    return $ConnectionString
}

Function Display-Progress($action, $percent){

    Write-Progress -Activity "Installing Publishing Service" -CurrentOperation $action -PercentComplete $percent
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

VerifyOrDownload-File -moduleName $moduleName -moduleResourceUrl $Urls[1][1] -progress 3
VerifyOrDownload-File -moduleName $serviceName -moduleResourceUrl $Urls[0][1] -progress 7

$Hostname = "publishing.$Website"
$parentFolder =  Split-Path $Webroot -Parent
$serviceFolderPath = "$parentFolder\$Hostname"
if([System.IO.Directory]::Exists($serviceFolderPath))
{
    "."
    Show-Message -Fore "Red" -Back "Yellow" -Text @("Folder $serviceFolderPath already exists.","","Please remove existing Publishing Service and try again")
    "."
    Write-Output "#COLOR:GREEN# Script operation complete."
    exit
}

Display-Progress -action "extracting Publishing Service files" -percent 10
$psFolder = New-Item -ItemType Directory -Path $serviceFolderPath -force

Write-Output "Sifon-MuteProgress"
Expand-Archive -Path $serviceFilename -DestinationPath $serviceFolderPath
Write-Output "Sifon-UnmuteProgress"

$Username = $SqlCredentials.GetNetworkCredential().username
$Password = $SqlCredentials.GetNetworkCredential().password

$core = Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "core"
$core = Replace-WithDatabaseAdmin -ConnectionString $core -Username $Username -Password $Password

$master = Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "master"
$master = Replace-WithDatabaseAdmin -ConnectionString $master -Username $Username -Password $Password

$web = Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "web"
$web = Replace-WithDatabaseAdmin -ConnectionString $web -Username $Username -Password $Password

if($Debug){
    "moduleName = $moduleName"
    "serviceName = $serviceName"
    "downloadsFolder = $downloadsFolder"
    "moduleFilename = $moduleFilename"
    "serviceFilename = $serviceFilename"
    "Hostname = $Hostname"
    "parentFolder =  $parentFolder"
    "serviceFolderPath = $serviceFolderPath"
    "psFolder = $psFolder"

    "core = $core"
    "master = $master"
    "web = $web"
}

$sitecoreruntime = New-Item -Path "$serviceFolderPath" -Name "sitecoreruntime" -ItemType "directory"
Copy-Item -Path "$Webroot\App_Data\license.xml" -Destination $sitecoreruntime

$sitecoreItems = New-Item -Path "$serviceFolderPath\items\sitecore" -ItemType "directory"
Copy-Item -Path "$Webroot\App_Data\items\master" -Destination $sitecoreItems -Recurse
Copy-Item -Path "$Webroot\App_Data\items\web" -Destination $sitecoreItems -Recurse

$exe =  "$serviceFolderPath\Sitecore.Framework.Publishing.Host.exe"

Display-Progress -action "setting connection strings: core" -percent 15
& $exe configuration setconnectionstring core $core

Display-Progress -action "setting connection strings: master" -percent 18
& $exe configuration setconnectionstring master $master

Display-Progress -action "setting connection strings: web" -percent 22
& $exe configuration setconnectionstring web $web

Display-Progress -action "setting instance name" -percent 26
& $exe configuration set Sitecore:Publishing:InstanceName --value $Website

Display-Progress -action "upgrading database schema" -percent 31
& $exe schema upgrade --force

Display-Progress -action "setting up site in IIS" -percent 41
& $exe iis install --hosts --sitename "$Hostname" --force


$appPoolState = [PowerShell]::Create().AddCommand("Get-WebAppPoolState").AddParameter("Name", $Hostname).Invoke()
if($appPoolState.Value -ne "Started")
{
    Write-Output "starting AppPool: $Hostname"
    Display-Progress -action "Starting AppPool" -percent 44
    [PowerShell]::Create().AddCommand("Start-WebAppPool").AddParameter("Name", $Hostname).Invoke()
}

$siteState = [PowerShell]::Create().AddCommand("Get-IISSite").AddParameter("Name", $Hostname).Invoke()
if($siteState.State -ne "Started")
{
    Write-Output "starting website: $Hostname"
    Display-Progress -action "Starting website" -percent 48
    [PowerShell]::Create().AddCommand("Start-Website").AddParameter("Name", $Hostname).Invoke()
}

[string]$endpointUri ="http://$Hostname/api/publishing/operations/status"
Display-Progress -action "validating installation status at $endpointUri" -percent 52
Write-Output "Validating installation status at $endpointUri"
$request = Invoke-WebRequest -Uri $endpointUri -UseBasicParsing
$response = $request | ConvertFrom-Json | Select Status
if($response.status -eq 0)
{
    Display-Progress -action "installing the Publishing Module" -percent 64
    Write-Output "Now, installing the Publishing module ..."
    if(Test-Path $moduleFilename -PathType leaf)
    {
        $InstanceUrl = Get-InstanceUrl -Webroot $Webroot
        Install-SitecorePackage -PackageFullPath $moduleFilename -Webroot $Webroot -Hostbase $InstanceUrl
        Write-Output "Publishing module installed."

        $content = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration xmlns:patch="http://www.sitecore.net/xmlconfig/">
    <sitecore>
        <settings>
            <setting name="PublishingService.UrlRoot">http://_HOSTNAME_/</setting>
        </settings>
    </sitecore>
</configuration>
'@
    
        Display-Progress -action "patching Publishing Module configuration" -percent 97
        $content = $content.Replace("_HOSTNAME_",$Hostname)
        Set-Content -Path "$Webroot\App_Config\Modules\PublishingService\Sitecore.Publishing.Service.Patched.config" -Value $content
        Write-Output "Publishing Module config patched."
        Start-Process -FilePath $exe -NoNewWindow

        "."
        Show-Message -Fore "Green" -Back "Yellow" -Text "Publishing Service and Module for Sitecore have been installed"
        Display-Progress -action "publishing service and its module for Sitecore have been installed" -percent 100
    }
}
else 
{
    Write-Error "Publishing Service isn't running at $endpointUri or returns incorrect status code."
}