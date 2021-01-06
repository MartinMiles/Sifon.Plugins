### Name: Create cores for SXA built-in indexes
### Description: Create cores for SXA built-in indexes: ***_sxa_master_index and ***_sxa_web_index
### Compatibility: Sifon 1.2.3

param(
    [string]$Webroot,
    [string]$Website,
    [string]$Prefix,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [uri]$Solr
)

Show-Progress -Percent 2 -Activity "Identifying Solr instances installed" 

Write-Output "Sifon-MuteProgress"
$instances = Find-SolrInstances 
$version = $instances | Where-Object { $_[0] -eq $Solr.Port } | select { $_[1] }
$folder = $instances | Where-Object { $_[0] -eq $Solr.Port } | select   { $_[2] }
Write-Output "Sifon-UnmuteProgress"

if($null -ne $folder)
{
    $folder = $folder.Psobject.Properties.Value
    $version = $version.Psobject.Properties.Value    

    if($version -match "@{solr-spec-version=(.*)}"){
        $version = $matches[1]
    }
    else{
        Show-Message -Fore Red -Back Yellow -Text "Cannot identify Solr version. Terminating..."
        exit
    }

    if($null -ne $folder)
    {
        Import-Module SitecoreInstallFramework -Force
        Show-Progress -Percent 31 -Activity "Now installing SXA Solr Cores" 
        "."
        $sitewebroot = $Webroot
        $PathToJson =  Split-Path -Path $PSCommandPath -Parent
        $SolrUrl = $Solr
        $SolrRoot = $folder.Replace("\server\solr","")
        $SolrService = "solr-$version"
        $SolrCorePrefix = $Prefix
        $SitecoreSiteName = $Website
        $SitecoreAdminPassword = $AdminPassword
        $sitewebroot = $Webroot

        $sxaIndexCreateParams = @{
            Path                  = "$PathToJson\Create-Cores-SXA-solr.json"
            SolrUrl               = $SolrUrl
            SolrRoot              = $SolrRoot
            SolrService           = $SolrService
            CorePrefix            = $SolrCorePrefix
            SiteName              = $SitecoreSiteName
            SitecoreAdminPassword = $SitecoreAdminPassword
            SiteWebRootPath       = $sitewebroot
            SuggesterJsonPath     = "$PathToJson\Create-Cores-SXA-config.json"
        }

        Write-Output "Sifon-MuteOutput"
        Write-Output "Sifon-MuteProgress"
            Install-SitecoreConfiguration @sxaIndexCreateParams
            # can also do: Uninstall-SitecoreConfiguration @sxaIndexCreateParams
        Write-Output "Sifon-UnmuteProgress"        
        Write-Output "Sifon-UnmuteOutput"

        Show-Message -fore white -back yellow -Text "SXA Solr Cores have been added into $folder"
        "."
    }
}
else{
    Show-Message -Fore Red -Back Yellow -Text "Failed to edintify Solr folder. Terminating..."
}

Show-Progress -Percent 100 -Activity "Finished" 