### Name: Prerequisites Step 2: switch to Windows containers
### Description: switching to Windows containers required prior building and running Sitecore images
### Compatibility: Sifon 0.98

Write-Output "Now switching to Windows Containers"
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon
Write-Progress -Activity "Switching to Windows containers" -CurrentOperation "complete." -PercentComplete 100