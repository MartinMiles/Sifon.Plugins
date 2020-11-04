### Name: Get Sifon plugins
### Description: Downloads the plugins from Sifon repository (requires git)
### Compatibility: Sifon 0.95

Write-output "Pulling scripts from a community repository on GitHub ..."
Write-output "Sifon-MuteOutput"

$pluginsFolder = Join-Path (Get-Location) -ChildPath "Sifon.Plugins"

Remove-Item -Path $pluginsFolder -Recurse -Force -Confirm:$false
git clone https://github.com/MartinMiles/Sifon.Plugins.git

Write-output "Sifon-UnmuteOutput"
Write-output "#COLOR:GREEN# Scripts were installed under Plugins menu."
