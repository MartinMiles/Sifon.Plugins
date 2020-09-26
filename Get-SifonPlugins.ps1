### Name: Get Sifon plugins
### Description: Downloads the plugins from Sifon repository (requires git)
### Compatibility: Sifon 0.95

Write-output "Sifon-MuteOutput"
Remove-Item -Path Sifon.Plugins -Recurse -Force -Confirm:$false
git clone https://github.com/MartinMiles/Sifon.Plugins.git

Write-output "Sifon-UnmuteOutput"
Write-output "#COLOR:GREEN# Scripts were installed under Plugins menu."
