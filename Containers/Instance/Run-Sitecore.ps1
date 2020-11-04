### Name: Build and run Sitecore
### Description: Builds (on a first run) and then runs Sitecore in Docker
### Compatibility: Sifon 1.00
### Local-only

param(
    [string]$ContainerProfileName,
    [string]$Repository,
    [string]$Folder,
    [string]$AdminPassword,
    [string]$SaPassword
)

Write-Warning "Just in case: if getting Traefik errors, please ensure that standard ports for HTTPS, Solr, SQL are released, so that they do not conflict with ports exposed by containers."

$BaseDir = (Get-Location).Path

$ContainersDirectory = New-Item -ItemType Directory -Path Containers -force
$ProfileContainersDirectory = "$BaseDir\Containers\$ContainerProfileName"


If (!(Test-Path -Path $ProfileContainersDirectory)){

    Write-Error "The folder $ProfileContainersDirectory not found. Have you renamed you profile recently?"
    exit
}

cd "$ProfileContainersDirectory"
Start-Process powershell -Wait -ArgumentList '-noexit -command "docker-compose up -d"'


# $UserResponse= [System.Windows.Forms.MessageBox]::Show("Sitecore in containers is ready. Would you like opening it in a browser?" , "Status" , 4)
# if ($UserResponse -eq 'YES') 
# {
#     start https://xp0cm.localhost/sitecore
# }

