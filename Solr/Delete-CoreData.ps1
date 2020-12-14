### Name: Remove website Solr core data
### Description: Delete Solr core data for the website
### Compatibility: Sifon 1.2.0

param
(
    [uri]$Solr,
    $Website,
    $Prefix
)

$folder = Find-SolrInstances | Where-Object { $_[0] -eq $Solr.Port } | select { $_[2] }
if($null -ne $folder)
{
    $folder = $folder.Psobject.Properties.Value

    $services = Get-Service solr* | Where { $_.Status -eq "Running" }
    $services | Stop-Service
    get-childitem -path "$folder\$Prefix*\Data" -recurse | remove-item -force -recurse
    $services | Start-Service

    $site = Get-WebSite $Website
    Restart-WebAppPool -Name $site.applicationPool

    "."
    Show-Message -fore White -back yellow -text "The data has been deleted for Solr cores prefixed with: $Prefix"
}
else{
    Show-Message -fore Red -back White -text "Failed to identfy running Solr for: $Solr"
}

