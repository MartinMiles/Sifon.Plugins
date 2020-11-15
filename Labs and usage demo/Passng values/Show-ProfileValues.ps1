### Name: Show profile values
### Description: Demostrates how you can pass a single profile into a script a consume its values
### Compatibility: Sifon 0.98

param($Profile)

Write-Output "."
Write-Output  "=================================================================="
Write-Warning "Parameters passed into this script with `$Profile and their values"
Write-Output  "=================================================================="
Write-Output "."

$Profile.PSObject.Properties | % {$_.Name + " = " + $_.Value}