### Name: Test if SPE Remoting enabled
### Description: Verifies if Sitecore PowerShell Extension with Remoting has been installed and enabled on a selected instance
### Compatibility: Sifon 1.0.1

param(
    [string]$Webroot,
    [string]$Website,
    [string]$AdminUsername,
    [string]$AdminPassword
)


Function Display-Progress($action, $percent){

    Write-Progress -Activity "Installing Sitecore PowerShell Extentions" -CurrentOperation $action -PercentComplete $percent
}

Display-Progress -action "testing PowerShell remoting on $Website instance" -percent 3

$InstanceUrl = Get-InstanceUrl -Webroot $Webroot


if (Get-Module -ListAvailable -Name SPE) {
    Import-Module SPE
} 
else {
    Show-Message -Fore "Red" -Back "Yellow" -Text "SPE Module does is not installed."
    Write-Output "."
    Write-Output "Instance URL: $InstanceUrl"
    exit
}

$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $InstanceUrl
if($null -eq $session)
{    
    Show-Message -Fore "Red" -Back "Yellow" -Text "Error: Remote session created"
    exit
}

$remoteSessionOutput = Invoke-RemoteScript -ScriptBlock {
    Get-Item -Path "master:\content" | Out-Null
    "Message from Sitecore: SPE Remoting works for the selected profile."
} -Session $session

if($null -ne $remoteSessionOutput)
{
    Write-Output "."
    Write-Warning $remoteSessionOutput
    Write-Output "."
    Show-Message -Fore LimeGreen -Back White -Text "Sitecore PowerShell Extensions has Remoting enabled on $Website instance"
}
else
{
    Write-Output "."
    Show-Message -Fore red -Back White -Text "Sitecore PowerShell Extensions not installed or failed remoting on $Website instance"

}

Display-Progress -action $result -percent 100