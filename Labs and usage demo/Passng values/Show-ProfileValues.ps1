### Name: Show profile values
### Description: Demostrates how you can pass a single profile into a script a consume its values
### Compatibility: Sifon 1.0.1

param($Profile)

Write-Output "."
Show-Message -Fore "Yellow" -Back "White" -Text "Parameters passed into this script with `$Profile and their values"
Write-Output "."

$Profile.PSObject.Properties | % {$_.Name + " = " + $_.Value}