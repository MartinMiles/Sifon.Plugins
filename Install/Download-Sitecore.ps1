### Name: Sitecore Resources Downloader
### Description: This plugin allows downloading all Sitecore resources from dev.sitecore.net in just one click
### Compatibility: Sifon 1.2.1
### $Selection = new Sifon.Shared.Forms.DownloaderDialog.Downloader::SelectProducts($Profile, "$PSScriptRoot\Download-Sitecore.json")

param(
    [string]$Webroot,
    $UseDownloadCDN,
    $Selection
)

if($null -eq $Selection){

    "."
    Show-Message -Fore white -Back yellow -Text "Operation cancelled by user"
    exit
}

# Verify-PortalCredentials -PortalCredentials $PortalCredentials
$OldFormat = "https://dev.sitecore.net/~/media/URL.ashx"
$NewFormat = "https://sitecoredev.azureedge.net/~/media/URL.ashx"

function Check-File
(
    [string]$FullPath,
    [long]$Size
)
{
    if(Test-Path -Path $FullPath)
    {
        $downloadedSize = ((Get-Item $FullPath).length)
        if($downloadedSize -eq $Size)
        {
            return $true
        }

        Write-Warning "Size mismatch for $Filename : expected $Size, received $downloadedSize"        
    }
    return $false
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
        Write-Progress -Activity "Downloading Sitecore resources" -CurrentOperation "downloading $Filename." -PercentComplete ($CurrentSize / $TotalSize * 100)
        

        $fileChecked = Check-File -FullPath $FullPath -Size $i.size
        if(!($fileChecked))
        {
            # Write-Output "Downloading: $Filename"

            $ResourceUrl = If ($UseDownloadCDN) {$NewFormat} Else {$OldFormat}
            Write-Output "Downloading: " + $ResourceUrl.Replace("URL",$i.url)
            Write-Output "Sifon-MuteProgress"
                Invoke-WebRequest -Uri $ResourceUrl.Replace("URL",$i.url) -OutFile $FullPath
                # Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $i.url -TargertFilename $FullPath
            Write-Output "Sifon-UnmuteProgress"
    
            $fileChecked = Check-File -FullPath $FullPath -Size $i.size
        }
        else
        {
            "Skipping successfully downloaded: $Filename"
        }
    }
    else
    {
        Write-Error "Skipping filepath that is too long: $Filename"
    }

    $CurrentSize += $i.size
}

 Write-Progress -Activity "Downloading Sitecore resources" -CurrentOperation "done." -PercentComplete 100

Write-Output '.'
Show-Message -Fore ForestGreen -Back White -Text "Downloading Sitecore resources completed successfully"
