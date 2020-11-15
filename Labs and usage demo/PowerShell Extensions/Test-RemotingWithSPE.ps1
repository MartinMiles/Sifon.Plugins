### Name: Test if SPE Remoting is enabled
### Description: Test if SPE Remoting is enabled on a selected profile instance
### Compatibility: Sifon 1.00

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword
)

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot
"Instance URL: $InstanceUrl"

Import-Module SPE
$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl

if($null -ne $session){
    "Remote session created"
}

Invoke-RemoteScript -ScriptBlock {
    Get-Item -Path "master:\content\Home" 
} -Session $session
