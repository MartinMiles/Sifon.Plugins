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


(get-childitem -Path ".\Sifon.Plugins" | where-object { $_.PSIsContainer }).Count

$folders = (get-childitem -Path ".\Sifon.Plugins" | where-object { $_.PSIsContainer }).Count
$scripts = (get-childitem -Path ".\Sifon.Plugins\*.ps1").Count

if($folders -ne 0 -or $scripts -ne 1)
{
    $result = [System.Windows.Forms.MessageBox]::Show("This operation with re-populate Sifon.Plugins folder deleting it firstly. Do you want to update the pligins from a public plugins repository? " , "Update the plugins?" , 4)
    if ($result -ne 'Yes') {
        "."
        Show-Message -Fore White -Back Yellow -Text "Operation terminated by user."
        exit
    }
}

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
        Write-Output "This plugin requires git installed locally to progress."
        "."
        Write-Output "Terminating, as you don't have it locally installed."
        Write-Output "You can install it eitherfrom under Settings menu or manually"
        exit
    }
    
Write-output "."
Write-output "Pulling scripts from a GitHub repository ..."
Write-output "Repository URL: $PluginsRepository"
Write-output "Branch: $VersionBranch"

$pluginsFolder = Join-Path (Get-Location) -ChildPath "Sifon.Plugins"

$tryBranch = (git ls-remote --heads $PluginsRepository $VersionBranch)
if($null -ne $tryBranch)
{
    Write-output "Sifon-MuteOutput"
        Remove-Item -Path $pluginsFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        git clone --single-branch --branch $VersionBranch $PluginsRepository Sifon.Plugins
    Write-output "Sifon-UnmuteOutput"

    Write-output "."
    Show-Message -Fore White -Back Yellow -Text "Scripts were installed under Plugins menu."
}
else 
{
    Write-output "."
    Show-Message -Fore red -Back Yellow -Text "Cancelling: branch $VersionBranch does not exist at remote $PluginsRepository"
}

