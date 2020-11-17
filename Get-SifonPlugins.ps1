### Name: Get Sifon plugins
### Description: Downloads the plugins from Sifon repository (requires git to be installed)
### Compatibility: Sifon 1.01
### Execution: Local

param([bool]$IsRemote)

if($IsRemote)
{
    Show-Message -Fore Red -Back White -Text "You are running on a remote profile"
    Write-Output "The script requires a local context"
    Write-Output "enforced in order to run correctly."
    Write-Warning "Exiting program..."
    exit    
}

$hasGitInstalled = Verify-Git

    if(!($hasGitInstalled))
    {
            Show-Message -Fore Red -Back White -Text "Git is not installed on this machine"
            Write-Output "This plugin requires git in order to progress."
            Write-Output "Cancelling, as you don't have it installed locally."
            Write-Output "You can install it eitherfrom under Settings menu or manually"
            exit
    }
    
Write-output "."
Write-output "Pulling scripts from a community repository on GitHub ..."
Write-output "Sifon-MuteOutput"

$pluginsFolder = Join-Path (Get-Location) -ChildPath "Sifon.Plugins"

Remove-Item -Path $pluginsFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
git clone https://github.com/MartinMiles/Sifon.Plugins.git

Write-output "Sifon-UnmuteOutput"
Write-output "."
Show-Message -Fore White -Back Yellow -Text "Scripts were installed under Plugins menu."