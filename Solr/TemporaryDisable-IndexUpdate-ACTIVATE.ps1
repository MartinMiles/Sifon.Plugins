### Name: Temporary Disable Index Update - Activate
### Description: This plugin creates a temporal config file to set all available indexed to manual update strategy
### Compatibility: Sifon 1.0.1

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword
)

$folder = "$Webroot\App_Config\Include\zzz"
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$ConfigFullPath = "$folder\z.Temporary_Disable_Index_Update_switching_to_manual_strategy.config"
$Indexes = Find-Indexes -Webroot $Webroot -AdminUsername $AdminUsername -AdminPassword $AdminPassword

"."
Show-Message -Fore "White" -Back "Yellow" -Text "Switching all available indexes to the manual update strategy"
"."
        $content = @'
<configuration xmlns:patch="http://www.sitecore.net/xmlconfig/" xmlns:set="http://www.sitecore.net/xmlconfig/set/">
    <sitecore>
      <contentSearch>
        <configuration type="Sitecore.ContentSearch.ContentSearchConfiguration, Sitecore.ContentSearch">
          <indexes hint="list:AddIndex">
_REPLACE_
          </indexes>
        </configuration>
      </contentSearch>
    </sitecore>
</configuration>
'@
    $indexNode = @'
<index id="_INDEX_">
    <strategies hint="list:AddStrategy">
        <strategy set:ref="contentSearch/indexConfigurations/indexUpdateStrategies/manual" />
    </strategies>
</index>
'@

[string]$indexesXml =''
Foreach ($index in $Indexes)
{
    "Processing index: $index"
    $indexesXml += $indexNode.Replace("_INDEX_",$index)
}

$content = $content.Replace("_REPLACE_",$indexesXml)
Set-Content -Path $ConfigFullPath -Value $content

"."
Show-Message -Fore "Lime" -Back "Yellow" -Text @("All the indexes have been switched to manual update strategy","","The configuration stored at: $ConfigFullPath")
Write-Progress -Activity "Temporary Disabling Index Update" -CurrentOperation "all the indexes have been switched to manual update strategy" -PercentComplete 100

