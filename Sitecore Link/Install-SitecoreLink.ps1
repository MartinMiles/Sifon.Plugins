### Name: Install Sitecore Link
### Description: Installs and deploys Sitecore Link on your local development machine (requires JSS module and CLI)
### Compatibility: Sifon 0.96. Requres Sifon PowerShell module

param(

    [string]$Webroot,
    [string]$Website,
    [string]$Solr = "https://localhost:8840/solr",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b"
)


# Variables
$ProjectDirectory = "c:\Projects"
$NewCoreName = "master_link_index"
$NewSitecoreLinkCore = $Website + "_" + $NewCoreName
$ThisScript = $MyInvocation.MyCommand.Definition


Function Display-Progress($action, $percent){

    Write-Progress -Activity "Installing Sitecore Link website" -CurrentOperation $action -PercentComplete $percent
}
Display-Progress -action "retrieving URL of Sitecore instance " -percent 3


[string]$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
Display-Progress -action "creating JSS API Key" -percent 5


Write-Output "Creating JSS API Key: establishing a remote SPE session ..."
$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl

$Guid = Invoke-RemoteScript -ScriptBlock {
    $item = New-Item -Path "master:/sitecore/system/Settings/Services/API Keys/jssKey" -Type "/System/Services/API Key"
    $item.'CORS Origins' = "*"
    $item.'AllowedControllers' = "*"
    Publish-Item -Item $item
    $item.ID.Guid
   
} -Session $session


Display-Progress -action "verifying JSS EndPoint with new API Key" -percent 9


Function Verify-EndPoint{
    
    Write-Output "=========================================================================================="
    Write-Output "=     JSS API Key: $Guid                                  ="
    Write-Output "=========================================================================================="

    $CheckEndpointUrl = "$InstanceUrl/sitecore/api/layout/render/jss?item=/&sc_apikey={$Guid}"
    $HTTP_Request = [System.Net.WebRequest]::Create($CheckEndpointUrl)
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    Write-Output "JSS Endpoint checked with status code: $HTTP_Status from Url: $CheckEndpointUrl"     
}
Verify-EndPoint


Push-Location


Display-Progress -action "getting project source code from GitHub" -percent 15


Function Prepare-Project{

    Write-Output "Sifon-MuteOutput"
        New-Item -ItemType Directory -Force -Path $ProjectDirectory
        cd $ProjectDirectory
    Write-Output "Sifon-UnmuteOutput"

    git clone https://github.com/MartinMiles/Sitecore.Link.git     
    cd "Sitecore.Link"


    #
    #   Working with configs
    #
    $Hostname = ([System.Uri]$InstanceUrl).Host
    $Configuration = "$((Get-Location).Path)\sitecore\config\sitecore-link.config"
    (Get-Content -Path $Configuration).Replace("<- REPLACE WITH YOUR HOSTNAME ->", $Hostname) | Set-Content -Path $Configuration

    $IndexConfiguration = "$((Get-Location).Path)\sitecore\config\Sitecore.ContentSearch.Solr.Index.Master.Link.config"
    (Get-Content -Path $IndexConfiguration).Replace("sc_master_link_index", $NewSitecoreLinkCore) | Set-Content -Path $IndexConfiguration

    $ConstanceConfig = "$((Get-Location).Path)\src\global\constants.js"
    (Get-Content -Path $ConstanceConfig).Replace("sitecore_web_link_index", "sitecore_master_link_index") | Set-Content -Path $ConstanceConfig


    Display-Progress -action "running npm install" -percent 18


    Write-Output "Sifon-MuteOutput"
        npm install
    Write-Output "Sifon-UnmuteOutput"
    Write-Output "All NPM packages have been installed. Now let's setup the app config:"
}
Prepare-Project


Display-Progress -action "installing Sitecore packages with the templates and sample data" -percent 27


Function Install-DataPackages{
    
    $PackageTemplates = "$((Get-Location).Path)\data\content\Sitecore.Link - Templates.zip"
    $PackageData = "$((Get-Location).Path)\data\content\Sitecore.Link - Data.zip"

    [string]$PackageToInstallTemplates = "$Webroot\App_Data\packages\Sitecore.Link - Templates.zip"
    [string]$PackageToInstallData = "$Webroot\App_Data\packages\Sitecore.Link - Data.zip"
    
    copy $PackageTemplates $PackageToInstallTemplates
    Write-Output "Package copied to: $PackageToInstallTemplates"
    copy $PackageData $PackageToInstallData
    Write-Output "Package copied to: $PackageToInstallData"
    
    #Set-ExecutionPolicy RemoteSigned
    Import-Module -Name SPE
    

    Write-Output "Sending SPE remote call to: $InstanceUrl"
    Write-Output "Sifon-MuteOutput"
        $session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
        Invoke-RemoteScript -ScriptBlock {
            Install-Package -Path "$($using:PackageToInstallTemplates)" -InstallMode Overwrite
            Install-Package -Path "$($using:PackageToInstallData)" -InstallMode Overwrite
        } -Session $session
    Write-Output "Sifon-UnmuteOutput"
}
Install-DataPackages



Display-Progress -action "installing a new Solr core: $($Website + "_" + $NewCoreName)" -percent 38


Function Install-SolrCore {

    Write-Output "Sifon-MuteOutput"
    Write-Output "Sifon-MuteProgress"
        $sitecoreParams = @{
            Path             = $ThisScript.Replace(".ps1", ".json")
            SolrUrl          = $Solr
            SolrService      = "solr-8.4.0"
            SolrRoot         = "c:\Solr\Solr-8.4.0"
            CorePrefix       = $Website
            CoreNameWithoutPrefix = $NewCoreName
        }
        Install-SitecoreConfiguration @sitecoreParams
    Write-Output "Sifon-UnmuteProgress"
    Write-Output "Sifon-UnmuteOutput"
    Write-Output "Added new Solr core: $($Website + "_" + $NewCoreName)"
}

Install-SolrCore 


#
#   Deploy configs and app
#
Function Get-Thumbprint {

    Write-Output "Need to find out the certificate thumbprint to use with deploy"
    $log = "$((Get-Location).Path)\deploy.log"

    Write-Output "Sifon-MuteOutput"
        Start-Transcript -Path $log
        jss deploy app -c -d --acceptCertificate test
        Stop-Transcript

        (Get-Content $log -Raw).Replace("`r`n","") | Set-Content $log -Force
        $LogContent = [IO.File]::ReadAllText($log)
        $script:Thumbprint = Select-String -InputObject $LogContent -Pattern "((\w{2}:){19}\w{2})" -AllMatches | % {$_.Matches.Groups[1].Value}
        
        Remove-Item -Path $log
    Write-Output "Sifon-UnmuteOutput"
    Write-Output "=========================================================================================="
    Write-Output "=     Obtained thumbprint: $Thumbprint   =" 
    Write-Output "=========================================================================================="
}

Display-Progress -action "setting up JSS site and deploying configs" -percent 41


jss setup --instancePath $Webroot --apiKey $Guid --deployUrl "$InstanceUrl/sitecore/api/jss/import" --layoutServiceHost $InstanceUrl --deploySecret "5bsa11x0rfdyunfsrgipmd3x44oyllcnzmty7xh6mq" --nonInteractive
jss deploy config

Display-Progress -action "attempting to retrieve certificate thumbprint" -percent 52


Get-Thumbprint


Display-Progress -action "deploying the app with the obtained thumbprint" -percent 61


Write-Output "Sifon-MuteOutput"
    jss deploy app -c -d --acceptCertificate $Thumbprint
Write-Output "Sifon-UnmuteOutput"


Function Process-NewIndex{

    $IndexName = "sitecore_$NewCoreName"

    Display-Progress -action "Populate Solr managed schema for index: $IndexName" -percent 77

    # Populate index managed schema
    Write-Output "Sifon-MuteOutput"
    Write-Output "Sifon-MuteProgress"
        $params = @{
            Path            = $ThisScript.Replace("Install-SitecoreLink.ps1", "Populate-Schema.json")
            Hostname        = $InstanceUrl
            IndexName       = $IndexName
            AdminUsername   = $AdminUsername
            AdminPassword   = "$AdminPassword"
        }
        Install-SitecoreConfiguration  @params
    Write-Output "Sifon-UnmuteProgress"
    Write-Output "Sifon-UnmuteOutput"
    Write-Output "Populated Solr managed schema for index: $IndexName"
    
    
    Display-Progress -action "Rebuilding new index: $IndexName" -percent 92


    # Finally rebuild the index at the new core
    $session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
    Invoke-RemoteScript -ScriptBlock { 
        Initialize-SearchIndex -Name  "$($using:IndexName)" 
    } -Session $session
    
    Write-Output "Index rebuilt: $IndexName"
}
 Process-NewIndex


Display-Progress -action "Operation complete" -percent 100

Pop-Location
Write-Output "#COLOR:GREEN# Operation complete"