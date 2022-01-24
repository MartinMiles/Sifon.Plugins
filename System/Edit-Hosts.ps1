### Name: Edit hosts file
### Description: Edit Windows hosts file on the selected profile machine
### Compatibility: Sifon 1.0.1
### $Content = new Sifon.Shared.Forms.TextEditorDialog.TextEditor::Read($Profile, "c:\Windows\System32\drivers\etc\hosts")
### Requires Profile: false

param(
    $Content
)

$HostsFile = "c:\Windows\System32\drivers\etc\hosts"

if($null -eq $Content)
{
    Write-Output "."
    Show-Message -Fore White -Back Yellow -Text @("Operation terminated", " ", "Host file has NOT been updated")
    exit
}

try{
    Set-Content -Path $HostsFile  -Value $Content
    
    Write-Output "."
    Show-Message -Fore White -Back Yellow -Text "Host file has been updated"
}
catch{
    Write-Output $_
} 