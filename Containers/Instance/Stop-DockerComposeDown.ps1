### Name: Stop Sitecore containers
### Description: Just a Sifon wraper for "docker-compose down" command
### Compatibility: Sifon 0.9.8

cd "Containers"
Start-Process powershell -Wait -ArgumentList '-noexit -command "docker-compose down"'
