### Name: Create cores for SXA built-in indexes
### Description: Create cores for SXA built-in indexes: ***_sxa_master_index and ***_sxa_web_index
### Compatibility: Sifon 1.2.3

param
(
    [uri]$Solr,
    $Prefix
)
    
$folder = Find-SolrInstances | Where-Object { $_[0] -eq $Solr.Port } | select { $_[2] }
if($null -ne $folder)
{
    $folder = $folder.Psobject.Properties.Value
    if($null -ne $folder)
    {
        "."
        # TODO: Verify if folder exists, notify for local or delete data without creating a folder
        Copy-Item "$folder\${Prefix}_master_index" "$folder\${Prefix}_sxa_master_index" -recurse
        Remove-Item -Recurse -Force "$folder\${Prefix}_sxa_master_index\data"
        Remove-Item -Force "$folder\${Prefix}_sxa_master_index\core.properties"
        "Created core: ${Prefix}_sxa_master_index"

        Copy-Item "$folder\${Prefix}_web_index" "$folder\${Prefix}_sxa_web_index" -recurse
        Remove-Item -Recurse -Force "$folder\${Prefix}_sxa_web_index\data"
        Remove-Item -Force "$folder\${Prefix}_sxa_web_index\core.properties"
        "Created core: ${Prefix}_sxa_web_index"

        "."
        Show-Message -fore White -back yellow -text "SXA Solr cores created. Now you may want populating managed schema followed by rebuilding SXA indexes"
    }
}
    $services = Get-Service solr* | Where { $_.Status -eq "Running" }
    $services | Stop-Service
    get-childitem -path "$folder\$Prefix*\Data" -recurse | remove-item -force -recurse
    $services | Start-Service
