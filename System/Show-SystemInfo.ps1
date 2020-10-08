### Name: Show system info
### Description: Shows information about the system for the selected profile

        Write-Output "-----------------------------------------"
        Write-Warning  "System Information for a Selected Profile"
        Write-Output "-----------------------------------------"
        Write-Output "."
        Write-Output "."

$product = (Get-WmiObject -class Win32_OperatingSystem).Caption
$build = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
Write-Output "$product, build $build"
Write-Output "."
"The current machine name is: $env:computername"
