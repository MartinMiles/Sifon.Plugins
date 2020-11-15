### Name: Test if SPE Remoting is enabled
### Description: Test if SPE Remoting is enabled on a selected profile instance
### Compatibility: Sifon 1.00

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword
)

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot

if (Get-Module -ListAvailable -Name SPE) {
    Import-Module SPE
} 
else {
    Write-Output  "================================="
    Write-Warning "SPE Module does is not installed."
    Write-Output  "================================="
    Write-Output "_"
    Write-Output "Instance URL: $InstanceUrl"
    exit
}

$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
if($null -eq $session)
{    
    Write-Output  "============================="
    Write-Error "Error: Remote session created"
    Write-Output  "============================="
    exit
}

$remoteSessionOutput = Invoke-RemoteScript -ScriptBlock {
    Get-Item -Path "master:\content\Home" | Out-Null
    "SPE Module is installed and works well"
} -Session $session

if($null -ne $remoteSessionOutput)
{
    Write-Output "."
    Write-Output  "======================================"
    Write-Warning $remoteSessionOutput
    Write-Output  "======================================"
}
