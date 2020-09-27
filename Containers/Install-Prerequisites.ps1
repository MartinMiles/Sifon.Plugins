# First of all ensure Hyper-V is enabled at your machine, if may be greyed out when running within a VM
# In that case, run the following command on THE HOST machine, just outside of VM:
# Set-VMProcessor -VMName <MACHINE NAME> -ExposeVirtualizationExtensions $true



# 1. Firstly, ensure Hyper-V is ON
$hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All | select DisplayName, FeatureName, State
if($hyperV.State -eq "Disabled")
{
    #Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart
}

# 2. Secondly, let's do Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation


# 3. Docker Desktop
choco install docker-desktop


# 4. WSL 2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

restart-computer

# Switch to Windows
#& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon