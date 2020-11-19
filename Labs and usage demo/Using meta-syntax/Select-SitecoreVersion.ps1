### Name: Version selector
### Description: Ask user to select Sitecore version
### Compatibility: Sifon 1.01
### $SelectedVersion = new Sifon.Shared.Forms.SitecoreVersionSelectorDialog.SitecoreVersionSelector::GetVersion("$Webroot\bin\Sitecore.Kernel.dll", "Sitecore version selector", "Please select Sitecore version:", "OK", $Profile)

param($SelectedVersion)

if($null -ne $SelectedVersion)
{    
    Show-Message -Fore "White" -Back "Yellow" -Text @('The version you have selected:', $SelectedVersion.Product)
}
