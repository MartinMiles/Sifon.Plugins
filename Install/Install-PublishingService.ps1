### Name: Install Publishing Service
### Description: Installs Sitecore Publishing Service
### Compatibility: Sifon 0.95

param(
	[string]$Webroot,
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "b",

    [string]$ServerInstance,
	[string]$Username,
	[string]$Password
)

#Write-Output "Sifon-MuteOutput"
    #Import-Module Sifon
    #Write-Output "Sifon-UnmuteOutput"

[string]$InstanceUrl = Get-InstanceUrl($Webroot)
$InstanceUrl


$moduleFilename = "Sitecore Publishing Module 10.0.0.0 rev. r00568.2697.zip"
$serviceFilename = "Sitecore Publishing Service 4.3.0-win-x64.zip"

if(Test-Path $moduleFilename -PathType leaf)
{
    if (-not ([string]::IsNullOrEmpty($ServerInstance)))
    {

    }
    else 
    {
        
    }
}


# if remote profile - need to copy to remote host

#   .\PowerShell\Core\Copy-ScriptToRemote.ps1
    # param(
    #     [string]$RemoteHost,
    #     [string]$Username,
    #     [string]$Password,
    #     [string]$RemoteDirectory,
    #     [string]$Filename #full path
    # )

# extract server into a directory

# do steps as normal documenteed (in a local or remote context) for a srevice

# copy module to packages folder 


# spe remoting to install

# config patching