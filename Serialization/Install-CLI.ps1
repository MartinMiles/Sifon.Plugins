### Name: Install Sitecore CLI
### Description: Instlls Sitecore CLI used for content serialization into a folder of choice
### Compatibility: Sifon 1.00
### $SelectedFolder = new Sifon.Shared.Forms.FolderBrowserDialog.FolderBrowser::GetFolder($Profile, $true)

param(
        $SelectedFolder
)

Push-Location
Set-Location -Path $SelectedFolder

dotnet new tool-manifest

dotnet tool install Sitecore.CLI --add-source https://sitecore.myget.org/F/sc-packages/api/v3/index.json

# https://doc.sitecore.com/developers/100/developer-tools/en/install-sitecore-command-line-interface.html

Pop-Location