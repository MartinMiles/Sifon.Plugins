### Name: Session Timeouts: Increase to the Max Values
### Description: Changes 4 settings used for session expiration to the maximal values
### Compatibility: Sifon 1.2.3

param
(
    [string]$Webroot,
    [string]$Website
)

"."
Show-Message -Fore gold -Back white -Text "Increasing Session expiration timeouts for $Website"
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
            $node[0].executionTimeout = "9000000"
            "Current:  " + $node[0].executionTimeout
            "Default:  600 (seconds)"
            "."
        }
        else 
        {
            "Value not set initially..."
            "Ignoring this parameter..."
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
            $node[0].executionTimeout = "1800"
            "Current:  " + $node[0].executionTimeout
            "Default:  180 (minutes)"
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
            $node[0].timeout = "525000"
            "Current:  " + $node[0].timeout
            "Default:  20 (minutes)"
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
        $node[0].value = "1800"
        "Current:  " + $node[0].value
        "Default:  60 (minutes)"

        Show-Message -Fore Yellow -Back White -Text @("Last change has been implemented on Sitecore.config file directly", "That means:", "1. If you overwrite it by Sitecore intaller - it will go away", "2. If you have a pacth file this setting may get overridded")
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