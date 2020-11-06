### Name: Get Sifon plugins
### Description: Downloads the plugins from Sifon repository (requires git to be installed)
### Compatibility: Sifon 1.00
### Local-only

$hasGitInstalled = Verify-Git

    if(!($hasGitInstalled))
    {
            Write-Output "------------------------------------"
            Write-Error  "Git is not installed on this machine"
            Write-Output "------------------------------------"
            Write-Output "This plugin requires git in order to progress."
            Write-Output "Cancelling, as you don't have it installed locally."
            Write-Output "You can install it eitherfrom under Settings menu or manually"
            exit
    }

Write-output "Pulling scripts from a community repository on GitHub ..."
Write-output "Sifon-MuteOutput"

$pluginsFolder = Join-Path (Get-Location) -ChildPath "Sifon.Plugins"

Remove-Item -Path $pluginsFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
git clone https://github.com/MartinMiles/Sifon.Plugins.git

Write-output "Sifon-UnmuteOutput"
Write-output "#COLOR:GREEN# Scripts were installed under Plugins menu."
