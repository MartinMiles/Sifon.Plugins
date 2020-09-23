### Name: Install Publishing Service
### Description: Installs Sitecore Publishing Service
### Compatibility: Sifon 0.96. Requres Sifon PowerShell module

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Username,  # SQL server admin username
    [string]$Password,  # SQL server admin password
    [string]$AdminUsername,
    [string]$AdminPassword
)

Function Replace-WithDatabaseAdmin($ConnectionString, $Username, $Password)
{
    $ConnectionString = $ConnectionString -replace "User ID=(\w+);", "User ID=$Username;"
    $ConnectionString = $ConnectionString -replace "Password=(\w+)", "Password=$Password"
    return $ConnectionString
}
Function Display-Progress($action, $percent){

    Write-Progress -Activity "Installing Publishing Service" -CurrentOperation $action -PercentComplete $percent
}

# Executes in local or remote context
# Assumed that the below file exists in Sifon root folder
$moduleFilename = "c:\Sifon\Sitecore Publishing Module 10.0.0.0 rev. r00568.2697.zip"   # must be full name
$serviceFilename = "Sitecore Publishing Service 4.3.0-win-x64.zip"

$Hostname = "$Website.publishing"
$parentFolder =  Split-Path $Webroot -Parent
$serviceFolderPath = "$parentFolder\$Hostname"
if(![System.IO.Directory]::Exists($serviceFolderPath))
{
    Display-Progress -action "extracting Publishing Service files" -percent 3
    $psFolder = New-Item -ItemType Directory -Path $serviceFolderPath -force
    Write-Output "Sifon-MuteProgress"
    Expand-Archive -Path $serviceFilename -DestinationPath $psFolder.FullName
    Write-Output "Sifon-UnmuteProgress"
}

$core = Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "core"
$core = Replace-WithDatabaseAdmin -ConnectionString $core -Username $Username -Password $Password

$master= Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "master"
$master = Replace-WithDatabaseAdmin -ConnectionString $master -Username $Username -Password $Password

$web= Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "web"
$web = Replace-WithDatabaseAdmin -ConnectionString $web -Username $Username -Password $Password

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
    Start-WebAppPool -Name "$Hostname"
}

$siteState = [PowerShell]::Create().AddCommand("Get-IISSite").AddParameter("Name", $Hostname).Invoke()
if($siteState.State -ne "Started")
{
    Write-Output "starting website: $Hostname"
    Display-Progress -action "Starting website" -percent 48
    Start-Website -Name "$Hostname"
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
        Install-SitecorePackage -InstanceUrl $InstanceUrl -Username $AdminUsername -Password $AdminPassword -Package $moduleFilename
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
        Start-Process -FilePath $exe  -NoNewWindow
        Write-Output "#COLOR:GREEN# Publishing Service and Module for Sitecore have been installed."
        Display-Progress -action "publishing service and its module for Sitecore have been installed" -percent 100
    }
}
else 
{
    Write-Error "Publishing Service isn't running at $endpointUri or returns incorrect status code."
}