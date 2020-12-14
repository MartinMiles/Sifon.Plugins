### Name: Sitecore Resources Downloader
### Description: This plugin allows downloading all Sitecore resources from dev.sitecore.net in just one click
### Compatibility: Sifon 1.2.1
### $Selection = new Sifon.Shared.Forms.DownloaderDialog.Downloader::SelectProducts($Profile, "$PSScriptRoot\Download-Sitecore.json")

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    $Selection
)

if($null -eq $Selection){

    "."
    Show-Message -Fore white -Back yellow -Text "Operation cancelled by user"
    exit
}

Verify-PortalCredentials -PortalCredentials $PortalCredentials

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Downloading Sitecore resources" -CurrentOperation $action -PercentComplete $percent
}

[long]$TotalSize = 0
Foreach ($i in $Selection){
    $TotalSize += $i.size
}

"."
$_totalSize = '{0:N0}' -f $TotalSize
Show-Message -Fore white -Back yellow -Text "Total to download: $_totalSize bytes"
"."

[long]$CurrentSize = 0
Foreach ($i in $Selection)
{
    $FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($i.path)
    $Directory = Split-Path $FullPath
    $Filename = Split-Path $FullPath -Leaf

    if($Filename.Length -lt 260)
    {
        New-Item -ItemType Directory -Force -Path $Directory | Out-Null
        Display-Progress -action "downloading $Filename." -percent ($CurrentSize / $TotalSize * 100)
        Write-Output "Downloading: $Filename"

        Write-Output "Sifon-MuteProgress"
            Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $i.url -TargertFilename $FullPath
        Write-Output "Sifon-UnmuteProgress"

        $downloadedSize = ((Get-Item $FullPath).length)
        if($downloadedSize -ne $i.size)
        {
            Write-Warning "Size mismatch for $Filename : expected $i.size, received $downloadedSize"
        }
    }
    else
    {
        Write-Error "Skipping filepath that is too long: $Filename"
    }

    $CurrentSize += $i.size
}

 Display-Progress -action "done." -percent 100

Write-Output '.'
Show-Message -Fore ForestGreen -Back White -Text "Downloading Sitecore resources completed successfully"
