### Name: Get Sifon plugins
### Description: Downloads the plugins from Sifon repository (requires git to be installed)
### Compatibility: Sifon 1.0.1
### Execution: Local

param(
    [bool]$IsRemote,
    [string]$PluginsRepository,
    [string]$VersionBranch,
    [string]$Website, 
    [string]$Solr,
    [string]$ServerInstance
)

if (!($Website -and $Solr -and $ServerInstance))
{
    "."
    Show-Message -Fore orange -Back White -Text @("PLEASE NOTE",`
     "you may see some menu items disabled until you set rest of the required settings:",`
      "1) select Website root folder - either auto-found or enter manually",`
      "2) create and select SQL Server connectivity",`
      "3) auto-select or manually provide URL for a Solr endpoint")
}

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
        "."
        Write-Output "Cancelling, as you don't have it installed locally."
        Write-Output "You can install it eitherfrom under Settings menu or manually"
        exit
    }
    
Write-output "."
Write-output "Pulling scripts from a GitHub repository ..."
Write-output "Repository URL: $PluginsRepository"
Write-output "Branch: $VersionBranch"

Write-output "Sifon-MuteOutput"

$pluginsFolder = Join-Path (Get-Location) -ChildPath "Sifon.Plugins"

Remove-Item -Path $pluginsFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
git clone --single-branch --branch $VersionBranch $PluginsRepository Sifon.Plugins

Write-output "Sifon-UnmuteOutput"
Write-output "."
Show-Message -Fore White -Back Yellow -Text "Scripts were installed under Plugins menu."