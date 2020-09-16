### Name: Install JSS 14.0 for Sitecore 10.0
### Description: Installs and deploys Sitecore Link on your local development machine
### Compatibility: Sifon 0.95, SIF, SPE Remoting, NPM. Works only for local profiles

param(

    [string]$Webroot,
    [string]$Website,
    [string]$Solr = "https://localhost:8840/solr",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b"
)

$configuration =  $MyInvocation.MyCommand.Definition.Replace(".ps1", ".json")
$PackageName = "Sitecore JavaScript Services Server for Sitecore 10.0.0 XP 14.0.0 rev. 200714.zip"
$jssUrl = "https://dev.sitecore.net/~/media/47F10159903D4D44A3CD66FEBEE6516E.ashx"



Function Get-SitecoreCredentials {
    if ($null -eq $global:credentials) {
        if ([string]::IsNullOrEmpty($devSitecoreUsername)) {
            $global:credentials = Get-Credential -Message "Please provide dev.sitecore.com credentials"
        }
        elseif (![string]::IsNullOrEmpty($devSitecoreUsername) -and ![string]::IsNullOrEmpty($devSitecorePassword)) {
            $secpasswd = ConvertTo-SecureString $devSitecorePassword -AsPlainText -Force
            $global:credentials = New-Object System.Management.Automation.PSCredential ($devSitecoreUsername, $secpasswd)
        }
        else {
            throw "Credentials required for download"
        }
    }
    $user = $global:credentials.GetNetworkCredential().UserName
    $password = $global:credentials.GetNetworkCredential().Password

    Invoke-RestMethod -Uri https://dev.sitecore.net/api/authorization -Method Post -ContentType "application/json" -Body "{username: '$user', password: '$password'}" -SessionVariable loginSession -UseBasicParsing
    $global:loginSession = $loginSession
}

Function Get-Jss {
    
    Write-Output "Let's take a look if we need to download a JSS package from Sitecore"

    if (!(Test-Path $PackageName)) {
        Get-SitecoreCredentials

        $params = @{
            Path         = $configuration
            LoginSession = $global:loginSession
            Source       = $jssUrl
            Destination  = "$((Get-Location).Path)\$PackageName"
        }
        $Global:ProgressPreference = 'SilentlyContinue'
        Install-SitecoreConfiguration  @params
        $Global:ProgressPreference = 'Continue'
    }
    else
    {
        Write-Output "No need to retrieve JSS as it already presents downloaded"
    }
}


Function Get-InstanceUrl {

    Import-Module WebAdministration
    $sites = Get-ChildItem -Path IIS:\Sites

    $dict = New-Object 'System.Collections.Generic.List[String[]]'
    Foreach ($site in $sites)
    {
        $path = $site.PhysicalPath.ToString()

        if($Webroot.TrimEnd('\') -eq $path)
        {
            $bindings = Get-WebBinding -Name $site.Name
            $bindings | ForEach-Object {
                [string[]]$arr = $_.protocol,$_.bindingInformation.Split(':')[2]
                $dict.Add($arr)
            }
        }
    }

    If($dict.Count -gt 0)
    {
        $Url = $dict[0][0] + "://" + $dict[0][1]
        return $Url 
    }
}
[string]$InstanceUrl = Get-InstanceUrl



Function Install-Jss {

    [string]$PackageToInstall = "$Webroot\App_Data\packages\$PackageName"
    
    copy $PackageName $PackageToInstall
    Write-Output "Package copied to: $PackageToInstall"
    
    Import-Module -Name SPE
    

    Write-Output "Creating a remote SPE session"
    $session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl

    Write-Output "Install JSS: Sending SPE remote call to: $InstanceUrl"

    Invoke-RemoteScript -ScriptBlock {
        Install-Package -Path "$($using:PackageToInstall)" -InstallMode Overwrite
    } -Session $session

    Write-Output "JSS installation complete."
}

Get-Jss
Install-Jss
npm install -g @sitecore-jss/sitecore-jss-cli