### Name: Local only plugin
### Description: This plugin uses meta-syntax to enforce its presence only for the local profiles
### Compatibility: Sifon 1.01
### Display: Local

Write-Output "."
Show-Message -Fore White -Back Yellow -Text "There are two options one may consider while creating locally running scripts:"
Write-Output "."
Write-Output "#COLOR:GREEN## Firstly, you may prevent showing your script plugin from a menu when remote profile selected with this header"
Write-Output '> ### Display: Local'
Write-Output "."
Write-Output "."
Write-Output '#COLOR:GREEN## If you want you script to be shown always but enfore it running locally regardles of selected profile type, then use'
Write-Output '> ### Execution: Local'
Write-Output "."
Write-Output "."
Write-Output "."
Show-Message -Fore LightBlue -Back Gray -Text "This plugin runs and shows up in the menu only when local profile is selected"