### Name: Add SifonClient to Identity Server
### Description: This script adds client to identity server so that Sifon can get access token
### Compatibility: Sifon 1.2.3

param([string]$Prefix)

$idsBase = Get-SiteFolder -Name $Prefix -type IdentityServer
$identityServerName = "$Prefix.identityserver"
$configFile = "$idsBase\Config\production\Sitecore.IdentityServer.Host.xml"

[xml]$config = Get-Content -Path $configFile
$sifonClient = $config.Settings.Sitecore.IdentityServer.Clients.SifonClient

if($null -eq $sifonClient)
{
    Write-Output "Sifon-MuteOutput"
    $child = $config.CreateElement("SifonClient")
    
    $id = $config.CreateElement("ClientId")
    $id.InnerText = 'sifon-api'
    $child.AppendChild($id)

    $id = $config.CreateElement("ClientName")
    $id.InnerText = 'sifon-api'
    $child.AppendChild($id)

    $id = $config.CreateElement("AccessTokenType")
    $id.InnerText = '0'
    $child.AppendChild($id)

    $id = $config.CreateElement("AllowOfflineAccess")
    $id.InnerText = 'true'
    $child.AppendChild($id)

    $id = $config.CreateElement("AlwaysIncludeUserClaimsInIdToken")
    $id.InnerText = 'false'
    $child.AppendChild($id)

    $id = $config.CreateElement("AccessTokenLifetimeInSeconds")
    $id.InnerText = '3600'
    $child.AppendChild($id)

    $id = $config.CreateElement("IdentityTokenLifetimeInSeconds")
    $id.InnerText = '3600'
    $child.AppendChild($id)

    $id = $config.CreateElement("AllowAccessTokensViaBrowser")
    $id.InnerText = 'true'
    $child.AppendChild($id)

    $id = $config.CreateElement("RequireConsent")
    $id.InnerText = 'false'
    $child.AppendChild($id)

    $id = $config.CreateElement("RequireClientSecret")
    $id.InnerText = 'true'
    $child.AppendChild($id)

    $id = $config.CreateElement("AllowedGrantTypes")
    $sub = $config.CreateElement("AllowedGrantType1")
    $sub.InnerText = 'password'
    $id.AppendChild($sub)
    $child.AppendChild($id)

    $id = $config.CreateElement("AllowedCorsOrigins")
    $child.AppendChild($id)

    $id = $config.CreateElement("AllowedScopes")
    $sub = $config.CreateElement("AllowedScope1")
    $sub.InnerText = 'openid'
    $id.AppendChild($sub)
    $sub = $config.CreateElement("AllowedScope2")
    $sub.InnerText = 'offline_access'
    $id.AppendChild($sub)
    $child.AppendChild($id)

    $id = $config.CreateElement("ClientSecrets")
    $sub = $config.CreateElement("ClientSecret1")
    $sub.InnerText = 'ClientSecret'
    $id.AppendChild($sub)
    $child.AppendChild($id)    

    $id = $config.CreateElement("UpdateAccessTokenClaimsOnRefresh")
    $id.InnerText = 'true'
    $child.AppendChild($id)

    $config.Settings.Sitecore.IdentityServer.Clients.AppendChild($child)

    $config.Save($configFile)

    Restart-WebAppPool $identityServerName
    Write-Output "Sifon-UnmuteOutput"
    "."
    Show-Message -Fore white -Back Yellow -Text @("Added SifonClient. Now you can obtain ID token, similar to below:"," ","Get-IdentityToken -identityserverUrl https://$Prefix.identityserver -username sitecore\admin -password b")
}
else
{
    "."
    Show-Message -Fore white -Back Yellow -Text @("SifonClient already installed for Identity Server"," ", "Config path: $configFile"," ", "You can obtain access token by using:"," Get-IdentityToken -identityserverUrl https://$Prefix.identityserver -username sitecore\admin -password b")
}
