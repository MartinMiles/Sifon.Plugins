### Name: Prerequisites Step 1: enable Hyper-V, containers and WSL2
### Description: Enable Hyper-V and containers, install Chocolatey and Docker Desktop and reboot
### Compatibility: Sifon 0.98


# First of all ensure Hyper-V is enabled at your machine, if may be greyed out when running within a VM
# In that case, run the following command on THE HOST machine, just outside of VM:
# Set-VMProcessor -VMName <MACHINE NAME> -ExposeVirtualizationExtensions $true

Add-Type -AssemblyName System.Windows.Forms
$UserResponse= [System.Windows.Forms.MessageBox]::Show("This machine will reboot at the end of current operation. Do you want to  continue?" , "Status" , 4)
if ($UserResponse -ne 'YES') 
{
    Write-Output "#COLOR:GREEN# Script finished."
    exit
}


# 1. Firstly, ensure Hyper-V is ON
Write-Progress -Activity "Sitecore in containers prerequisites" -CurrentOperation "enabling Hyper-V services" -PercentComplete 4
$hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All | select DisplayName, FeatureName, State
if($hyperV.State -eq "Disabled")
{
    Write-Output "Sifon-MuteProgress"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart
    Write-Output "Sifon-UnmuteProgress"
}


# 2. Secondly, let's do Chocolatey
Write-Progress -Activity "Sitecore in containers prerequisites" -CurrentOperation "installing Chocolatey" -PercentComplete 31
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Write-Output "Sifon-MuteProgress"
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n=allowGlobalConfirmation
Write-Output "Sifon-UnmuteProgress"

# 3. Docker Desktop
Write-Progress -Activity "Sitecore in containers prerequisites" -CurrentOperation "installing Docker Desktop" -PercentComplete 47
Write-Output "Sifon-MuteOutput"
Write-Output "Sifon-MuteProgress"
    choco install docker-desktop
Write-Output "Sifon-UnmuteProgress"
Write-Output "Sifon-UnmuteOutput"

# 4. WSL 2
Write-Progress -Activity "Sitecore in containers prerequisites" -CurrentOperation "installing WSL 2" -PercentComplete 85
Write-Output "Sifon-MuteOutput"
Write-Output "Sifon-MuteProgress"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Write-Output "Sifon-UnmuteProgress"
Write-Output "Sifon-UnmuteOutput"

Write-Progress -Activity "Sitecore in containers prerequisites" -CurrentOperation "restarting" -PercentComplete 100
restart-computer
