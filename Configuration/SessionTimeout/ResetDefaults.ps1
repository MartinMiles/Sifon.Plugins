### Name: Session Timeouts: Resetting the defaults
### Description: Changes 4 settings used for session expiration to their defaults
### Compatibility: Sifon 1.2.3

param
(
    [string]$Webroot,
    [string]$Website
)

"."
Show-Message -Fore gold -Back white -Text "Resetting default Session expiration timeouts for $Website"
"."
"."

$WebConfig = "$Webroot\web.config"
if([System.IO.File]::Exists($WebConfig))
{
    $xml = [xml](get-content $WebConfig)

    # 1. httpRuntime
    $node = $xml.SelectNodes("/configuration/system.web/httpRuntime")
    if($node)
    {
        if($node[0].executionTimeout)
        {
            "======================================================================"
            'Web.config: /configuration/system.web/httpRuntime["executionTimeout"]:'        
            "Previous: " + $node[0].executionTimeout
            $node[0].executionTimeout = "600"
            "Default:  " + $node[0].executionTimeout
            "."
        }
        else 
        {
            "Value not set initially..."
            "Ignoring this parameter..."
            "."
        } 
    }
    else
    {
        Write-Output "No database information found"
    }

    # 2. forms ASPXAUTH
    $node = $xml.SelectNodes("/configuration/system.web/authentication/forms[@name='.ASPXAUTH']")
    if($node)
    {
        "======================================================================"
        'Web.config: /configuration/system.web/authentication/forms[@name=".ASPXAUTH"]:'
        if($node[0].timeout)
        {
            "Previous: " + $node[0].timeout
            $node[0].executionTimeout = "180"
            "Default:  " + $node[0].executionTimeout
            "."
        }
        else
        {
            "Value not set initially..."
            "Ignoring this parameter..."
            "."
        }
    }
    else
    {
        Write-Output "No database information found"
    }

    # 3. SessionState timeout
    $node = $xml.SelectNodes("/configuration/system.web/sessionState")
    if($node)
    {
        if($node[0].timeout)
        {
            "=============================================================="
            'Web.config: /configuration/system.web/sessionState["timeout"]:'
            "Previous: " + $node[0].timeout
            $node[0].timeout = "20"
            "Default:  " + $node[0].timeout
            "."
        }
        else 
        {
            "Value not set initially..."
            "Ignoring this parameter..."
            "."
        } 
    }
    else
    {
        Write-Output "No database information found"
    }
}
else
{
    Write-Output "Config does not exist at: $WebConfig"
}
$xml.Save($WebConfig)



# 4. Sitecore.config setting[@name='Authentication.ClientSessionTimeout']
$SitecoreConfig = "$Webroot\App_Config\Sitecore.config"
if([System.IO.File]::Exists($SitecoreConfig))
{
    $xml = [xml](get-content $SitecoreConfig)
    $node = $xml.SelectNodes("/sitecore/settings/setting[@name='Authentication.ClientSessionTimeout']")
    if($node)
    {
        "============================================"
        'Sitecore.config: /sitecore/settings/setting'
        "Previous: " + $node[0].value
        $node[0].value = "60"
        "Default:  " + $node[0].value
        "."        
    }
    else
    {
        Write-Output "No 'Authentication.ClientSessionTimeout' setting found"
        "."
    }
}
else
{
    Write-Output "Config does not exist at: $SitecoreConfig"
}

$xml.Save($SitecoreConfig)
"."
"."
Show-Message -Fore LimeGreen -Back White -Text "Operation completed successfully."