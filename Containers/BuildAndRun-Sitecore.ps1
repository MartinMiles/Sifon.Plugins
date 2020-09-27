### Name: Build and run Sitecore
### Description: Builds (on a first run) and then runs Sitecore in Docker
### Compatibility: Sifon 0.98


$UserResponse= [System.Windows.Forms.MessageBox]::Show("Prior starting docker please ensure tha standard ports for HTTPS, Solr, SQL are released. Do you want to continue?" , "Status" , 4)
if ($UserResponse -ne 'YES') 
{
    Write-Output "#COLOR:GREEN# Script finished."
    exit
}


cd "Containers"
Start-Process powershell -Wait -ArgumentList '-noexit -command "docker-compose up -d"'


start https://xp0cm.localhost/sitecore
