### Name: SXA installer - for CD server (XM topology only)
### Description: Installs SXA CD packages (local CD websites only)
### Compatibility: Sifon 1.3.5
### $Urls = new Sifon.Shared.Forms.PackageVersionSelectorDialog.PackageVersionSelector::GetFile("$PSScriptRoot\Install-SXA-CD.json")

param(
    [string]$Webroot,
    [PSCredential]$PortalCredentials,
    [string[][]]$Urls,
    $Profile
)

$Webroot = $Profile.CDSiteRoot

Function Display-Progress($action, $percent){
    Write-Progress -Activity "Installing SXA packages" -CurrentOperation $action -PercentComplete $percent
}

Function VerifyOrDownload-File($moduleName, $moduleResourceUrl, $progress)
{
    $fullPath = (Get-Location).Path + "\Downloads\$moduleName"


    If(!(Test-Path -Path $fullPath))
    {
        # Verify-PortalCredentials -PortalCredentials $PortalCredentials

        Write-Output "Downloading $moduleName package from Sitecore Developers Portal..."
        Display-Progress -action "downloading $moduleName package from Sitecore Developers Portal." -percent $progress
    
        Write-Output "Sifon-MuteProgress"
            Download-Resource -PortalCredentials $PortalCredentials -ResourceUrl $moduleResourceUrl -TargertFilename $fullPath
        Write-Output "Sifon-UnmuteProgress"

        
    }
    else
    {
        Write-Output "Found package $moduleName already downloaded within Downloads folder."
    }

    "Extracting " + $fullPath
    $destinationFolder = "c:\Program Files\Sifon\Downloads\SXA-CD"

    Expand-Archive -Path $fullPath -DestinationPath $destinationFolder
    $package = Join-Path -Path $destinationFolder -ChildPath "package.zip"
    Expand-Archive -Path $package -DestinationPath $destinationFolder
    Copy-Item -Path "$destinationFolder\files\*" -Destination $Webroot -Recurse -Force

    if (Test-Path -Path $destinationFolder -PathType Container) {
        Remove-Item -Path $destinationFolder -Recurse
    }
}

if($null -eq $Urls){

    Write-Warning "No resources passed for the selected resources"
    exit
}

New-Item -ItemType Directory -Force -Path "Downloads" | Out-Null

$CurrentProgress = 10;

ForEach ($Url in $Urls) 
{
    $found = $Url[1] -match '\/([0-9a-fA-F]+)\.ashx'
    if ($found) 
    {
        $fileName = $Url[0].Replace(" ", "_") + ".zip"
        $downloadsFolder = New-Item -ItemType Directory -Path  "$((Get-Location).Path)\Downloads" -force
        $packageFullPath = "$downloadsFolder\$fileName"

        VerifyOrDownload-File -moduleName $fileName -moduleResourceUrl $Url[1] -progress $CurrentProgress
        
        $CurrentProgress += 20
        Display-Progress -action "appending sxaxm:define key to web.config" -percent $CurrentProgress

        $webConfigPath = "$Webroot\web.config"
        $newKey = "sxaxm:define"
        $newValue = "sxaxmonly"

        # Load the XML content of the web.config file
        [xml]$webConfig = Get-Content -Path $webConfigPath

        # Check if the <appSettings> section exists
        if ($webConfig.configuration.appSettings -eq $null) {
            # If it doesn't exist, create the <appSettings> section
            $appSettings = $webConfig.CreateElement("appSettings")
            $webConfig.configuration.AppendChild($appSettings)
        } else {
            $appSettings = $webConfig.configuration.appSettings
        }

        $existingKey = $appSettings.SelectSingleNode("add[@key='$newKey']")

        if ($existingKey -eq $null) {
            # If the key doesn't exist, create a new <add> element
            $newAddElement = $webConfig.CreateElement("add")
            $newAddElement.SetAttribute("key", $newKey)
            $newAddElement.SetAttribute("value", $newValue)

            # Append the new <add> element to <appSettings>
            $appSettings.AppendChild($newAddElement)

            # Save the modified web.config file
            $webConfig.Save($webConfigPath)

            Write-Host "Key '$newKey' with value '$newValue' has been added to <appSettings>."
        } else {
            Write-Host "Key '$newKey' already exists in <appSettings>. No changes made."
        }
        $CurrentProgress+=20
    }    
}
Write-Output '.'
Show-Message -Fore Green -Back White -Text "Sitecore Experience Accellerator (SXA) for content delicery (CD) have been installed", "", "Do not forget to pubish SXA items and rebuild the indexes at your CM instance"
Display-Progress -action "done." -percent 100

