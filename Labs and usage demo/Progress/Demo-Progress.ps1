### Name: Returning progress
### Description: Demonstrates who to create responsive sripts that return current activity name and status and update progress bar
### Compatibility: Sifon 1.0.1
### Requires Profile: false

Write-Output "."
Show-Message -Fore White -Back Yellow -Text "There are two ways of reporting activity and percentage status to Sifon to show a progress bar:"
Write-Output "."
Write-Output "#COLOR:GREEN## Build-in PowerShell way - as you normally do"
Write-Output '> Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 7" -PercentComplete 70'
Write-Output "."
Write-Output "."
Write-Output '#COLOR:GREEN## Sifon module function is slightly nicer'
Write-Output '> Show-Progress -Percent 40 -Activity "This is the name of current operation" -Status "Step 4"'
Write-Output "."
Write-Output "."
Write-Output "#COLOR:GREEN## Sifon simplified - send only percentage"
Write-Output '> Show-Progress -Percent 40'

start-sleep -milli 500

Show-Progress -Percent 10 

start-sleep -milli 500
Show-Progress -Percent 20 -Activity "This is the name of current operation" 

start-sleep -milli 500
Show-Progress -Percent 30  -Status "Step 3"

start-sleep -milli 500
Show-Progress -Percent 40  -Activity "This is the name of current operation"  -Status "Step 4"

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 5" -PercentComplete 50

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 6" -PercentComplete 60

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 7" -PercentComplete 70

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 8" -PercentComplete 80

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 9" -PercentComplete 90

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 10" -PercentComplete 100

