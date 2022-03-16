### Name: Compatibility test
### Description: This used to develop functionality for the compatibility contraint (the below line)
### Compatibility: Sifon 1.0.1
### Requires Profile: false

Write-Output "."
Show-Message -Fore White -Back Yellow -Text "You can ensure the minimun version of Sifon for your script to run:"
Write-Output "."
Write-Output "#COLOR:GREEN## This header prevents your script from showing at older versions of Sifon"
Write-Output '> ### Compatibility: Sifon 1.0.1'