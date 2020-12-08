Add-Type -AssemblyName System.Drawing
$Colors = [Enum]::GetNames([System.Drawing.KnownColor])

Show-Message -fore white -back darkorange -text @("Using colors with Sifon", "Color codes for your scripts' output")
"."
"These are the all the possible combintaions of color codes to be used with Sifon"
"."
"."

foreach ($Color in $Colors) {
    # Write-Output "$Color" -ForegroundColor $Color
    # Write-Host "$Color " -ForegroundColor "$Color" -NoNewline;
    Write-Output "#COLOR:$Color# $Color"
    
}