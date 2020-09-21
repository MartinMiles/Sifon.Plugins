### Name: Install Publishing Service
### Description: Installs Sitecore Publishing Service
### Compatibility: Sifon 0.95

param(
    [string]$Webroot,
    [string]$Website,

    [string]$Username,  # sa
    [string]$Password,  # SA_PASSWORD

    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b"

    # [string]$ServerInstance,
	# [string]$RemoteUsername,
    # [string]$RemotePassword,
    # [string]$RemoteDirectory
)

Function Replace-WithDatabaseAdmin($ConnectionString, $Username, $Password)
{
    $ConnectionString = $ConnectionString -replace "User ID=(\w+);", "User ID=$Username;"
    $ConnectionString = $ConnectionString -replace "Password=(\w+)", "Password=$Password"
    return $ConnectionString
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
    $psFolder = New-Item -ItemType Directory -Path $serviceFolderPath -force
    Expand-Archive -Path $serviceFilename -DestinationPath $psFolder.FullName
}

# remove the line below
Import-Module "c:\Sifon\PowerShell\Module\Sifon.psm1"

$core = Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "core"
$core = Replace-WithDatabaseAdmin -ConnectionString $core -Username $Username -Password $Password

$master= Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "master"
$master = Replace-WithDatabaseAdmin -ConnectionString $master -Username $Username -Password $Password

$web= Get-ConnectionString -ConfigPath "$Webroot\App_Config\ConnectionStrings.config" -DbName "web"
$web = Replace-WithDatabaseAdmin -ConnectionString $web -Username $Username -Password $Password

$exe =  "$serviceFolderPath\Sitecore.Framework.Publishing.Host.exe"

& $exe configuration setconnectionstring core $core
& $exe configuration setconnectionstring master $master
& $exe configuration setconnectionstring web $web

& $exe configuration set Sitecore:Publishing:InstanceName --value $Website
& $exe schema upgrade --force
& $exe iis install --hosts --sitename "$Hostname" --force

$appPoolState = Get-WebAppPoolState -Name $Hostname
if($appPoolState.Value -ne "Started")
{
    Start-WebAppPool -Name "$Hostname"
}
$siteState = (Get-IISSite -Name $Hostname).State
if($siteState -ne "Started")
{
    Start-Website -Name "$Hostname"
}

$endpointUri ="http://$Hostname/api/publishing/operations/status"
Write-Output "Validating installation status at $endpointUri"
$request = Invoke-WebRequest -Uri $endpointUri -UseBasicParsing
$response = $request | ConvertFrom-Json | Select Status
if($response.status -eq 0)
{
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
        
        $content = $content.Replace("_HOSTNAME_",$Hostname)
        Set-Content -Path "$Webroot\App_Config\Modules\PublishingService\Sitecore.Publishing.Service.Patched.config" -Value $content
        Write-Output "Publishing Module config patched."
    }
}
else 
{
    Write-Error "Publishing Service isn't running at $endpointUri or returns incorrect status code."
}