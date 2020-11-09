### Name: Returning progress
### Description: Demonstrates who to create responsive sripts that return current activity name and status and update progress bar
### Compatibility: Sifon 0.95

echo 'Hello from echo'

Write-Host "It is not recommended to use Write-Host method"
Write-Output "This is a better way of writing console output - use Write-Output method"

start-sleep -milli 500
Write-Information "Information"


#start-sleep -milli 500
#Write-Error "This was an error"


start-sleep -milli 500
Write-Warning "This was a warning"


start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 1" -PercentComplete 10

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 2" -PercentComplete 20

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 3" -PercentComplete 30

start-sleep -milli 500
Write-Progress -Activity "This is the name of current operation" -CurrentOperation "Step 4" -PercentComplete 40

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
