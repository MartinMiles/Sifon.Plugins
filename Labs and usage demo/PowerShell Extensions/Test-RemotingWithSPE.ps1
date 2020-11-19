### Name: Test if SPE Remoting is enabled
### Description: Test if SPE Remoting is enabled on a selected profile instance
### Compatibility: Sifon 1.01

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword
)

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot

if (Get-Module -ListAvailable -Name SPE)
{
    Import-Module SPE
} 
else {
    Show-Message -Fore "Red" -Back "Yellow" -Text "SPE Module does is not installed."
    Write-Output "_"
    Write-Output "Instance URL: $InstanceUrl"
    exit
}

$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
if($null -eq $session)
{    
    Show-Message -Fore "Red" -Back "Yellow" -Text "Error: Remote session not created"
    exit
}

$remoteSessionOutput = Invoke-RemoteScript -ScriptBlock {
    Get-Item -Path "master:\content\Home" | Out-Null
    "SPE Module is installed and works well"
} -Session $session

if($null -ne $remoteSessionOutput)
{
    Write-Output "."
    Show-Message -Fore "White" -Back "Yellow" -Text $remoteSessionOutput
}
