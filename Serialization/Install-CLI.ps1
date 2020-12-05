### Name: Install Sitecore CLI
### Description: Instlls Sitecore CLI used for content serialization into a folder of choice
### Compatibility: Sifon 1.0.0
### $SelectedFolder = new Sifon.Shared.Forms.FolderBrowserDialog.FolderBrowser::GetFolder($Profile, $true)

param($SelectedFolder)

if(!(Verify-NetCore -Type 'SDK'))
{
    Show-Message -Fore "Red" -Back "Yellow" -Text @("Cannot install Sitecore CLI as it required .NET Core SDK to be installed","You can install it as a prerequisite from under Settings menu")
    exit
}

if($null -ne $SelectedFolder)
{
    Show-Message -Fore "White" -Back "Yellow" -Text @("The folder you have selected:", $SelectedFolder)
}
else
{
    Show-Message -Fore "Red" -Back "Yellow" -Text "You should provide the folder to install Sitecore CLI"
    exit
}

Push-Location
Set-Location -Path $SelectedFolder

dotnet new tool-manifest
dotnet tool install Sitecore.CLI --add-source https://sitecore.myget.org/F/sc-packages/api/v3/index.json

Pop-Location

Show-Message -Fore "White" -Back "Green" -Text "Sitecore CLI successfully installed at: $SelectedFolder"
