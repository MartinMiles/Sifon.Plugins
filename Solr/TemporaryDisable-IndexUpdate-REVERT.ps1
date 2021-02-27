### Name: Temporary Disable Index Update - Revert
### Description: This plugin reverts all available indexed to their previous update strategy by removing temporal config file
### Compatibility: Sifon 1.0.1

param(
    [string]$Webroot
)

$folder = "$Webroot\App_Config\Include\zzz"
$ConfigFullPath = "$folder\z.Temporary_Disable_Index_Update_switching_to_manual_strategy.config"

"."
"Deleting $ConfigFullPath ..."

rm $ConfigFullPath -ErrorAction Ignore

if((gci $folder).count -eq 0 )
{
    Remove-Item $folder -Force
}

"."
    Show-Message -Fore "White" -Back "Yellow" -Text "Temporal config switching all available indexes to the manual update strategy has been removed"
"."
