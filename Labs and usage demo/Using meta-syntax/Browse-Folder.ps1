### Name: Folder selector
### Description: Works on both remote and local
### Compatibility: Sifon 1.0.1
### $SelectedFolder = new Sifon.Shared.Forms.FolderBrowserDialog.FolderBrowser::GetFolder($Profile, $true)

param($SelectedFolder)

Show-Message -Fore "White" -Back "Yellow" -Text @('The folder you have selected:', $SelectedFolder)