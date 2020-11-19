### Name: Populates Managed Schema
### Description: Populates Managed Schema for a specifix index or all of them
### Compatibility: Sifon 1.01
### Dependencies: "Populate-Schema.json"
### $Indexes = new Sifon.Shared.Forms.IndexSelectorDialog.IndexSelector::GetIndex($Profile)

param(
    [string]$Webroot,
    [string]$IndexName = "sitecore_master_index",
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string[]]$Indexes
)


if($null -eq $Indexes)
{
    Show-Message -Fore Red -Back Yellow -Test "Sitecore PowerShell Remoting required for running this script is not installed"
    exit
}

if($Indexes.Length -le 0){
    Show-Message -Fore Yellow -Back White -Text "No index to rebuild as user cancelled operation."
    exit
}

[string]$Hostname = Get-InstanceUrl -Webroot $Webroot
$path = $MyInvocation.MyCommand.Definition.Replace(".ps1", ".json")

[int]$indexCount = $Indexes.Length
for ($i=0; $i -lt $indexCount; $i++) 
{
    $idxName = $Indexes[$i]

    Show-Progress -Percent $pc -Activity "Rebuilding indexes" -Status $idxName

    $params = @{
        Path            = $path 
        Hostname        = $Hostname
        IndexName       = $idxName
        AdminUsername   = $AdminUsername
        AdminPassword   = $AdminPassword
    }

    Write-Output "#COLOR:YELLOW#Populating managed schema for index: $IndexName ..."
    Write-Output "Sifon-MuteOutput"
        Install-SitecoreConfiguration  @params
    Write-Output "Sifon-UnmuteOutput"

    [int]$pc = $i / $indexCount * 100
    
    Write-Output "Schema for index $idxName successfully populated"   
    Write-Output "."
}


Show-Message -Fore Green -Back White -Text "Operation complete."