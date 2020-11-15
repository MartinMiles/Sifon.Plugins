### Name: Sync all Unicorn configurations
### Description: The plugin will sync all Unicorn configurations from serialized items into Sitecore
### Compatibility: Sifon 1.01

param(
    [string]$Webroot
    # [string]$Website,
    # [string]$Prefix,
    # [string]$AdminUsername,
    # [string]$AdminPassword,
    # [PSCredential]$SqlCredentials,
    # [PSCredential]$PortalCredentials
)

$ModuleUrl = 'https://raw.githubusercontent.com/SitecoreUnicorn/Unicorn/master/doc/PowerShell%20Remote%20Scripting/Unicorn.psm1'
$MicroChapUrl = 'https://github.com/SitecoreUnicorn/Unicorn/raw/master/doc/PowerShell%20Remote%20Scripting/MicroCHAP.dll'

$folder = ".\Downloads\Unicorn"

New-Item -ItemType Directory -Force -Path $folder | Out-Null

$UnicornModule = "$folder\Unicorn.psm1"
$MicroChap = "$folder\MicroCHAP.dll"


$ProgressPreference = "SilentlyContinue"
if(!(Test-Path $UnicornModule)) {
    Start-BitsTransfer -Source $ModuleUrl -Destination $UnicornModule
}

if(!(Test-Path $MicroChap)){
    Invoke-WebRequest $MicroChapUrl -OutFile $MicroChap
}
$ProgressPreference = "Continue"

Import-Module ".\$UnicornModule"

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
$syncUnicornUrl = $InstanceUrl + "/unicorn.aspx";
 
$IncludeFolder = "$Webroot\App_Config\Include"
$ConfigMatchPattern = "<SharedSecret>(.+)<\/SharedSecret>"

$files = Get-ChildItem -Path $IncludeFolder -Recurse -Filter "*.config" `
    | Select-String -Pattern $ConfigMatchPattern `
    | Select Path `
    | Select-Xml -XPath "/configuration/sitecore/unicorn/authenticationProvider/SharedSecret" `
    | Select-Object -ExpandProperty Node


    $SharedSecret = $files.InnerText
        
    $errorLine1 = "Failed to obtain Unicorn secret from under $IncludeFolder folder."
    if($null -eq $SharedSecret)
    {
        Show-Message -Fore "Red" -Back "Yellow" -Text @($errorLine1,"There isn't any of config files having <SharedSecret> provided. Cannot contunue with sync, terminating")
        exit
    }

    if(!($SharedSecret -is [string]))
    {
        Show-Message -Fore "Red" -Back "Yellow" -Text @($errorLine1,"Found too many configuration files having <SharedSecret> node under the above folder. Script requires only one")
        exit        
    }

try{
    Sync-Unicorn -ControlPanelUrl $syncUnicornUrl -SharedSecret $SharedSecret
}
catch{ 
    Show-Message -Fore "Red" -Back "Yellow" -Text $Error[0]
}

if(Test-Path $UnicornModule){
    Remove-Module Unicorn
}
