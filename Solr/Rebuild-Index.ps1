### Name: Rebuild indexes
### Description: Rebilds indexes via SPE remoting
### Compatibility: Sifon 1.01
### Display: (Non)Local
### $Indexes = new Sifon.Shared.Forms.IndexSelectorDialog.IndexSelector::GetIndex($Profile)

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string[]]$Indexes
)



if($Indexes.Length -le 0){
    Show-Message -Fore Yellow -Back White -Text "No index to rebuild as user cancelled operation."
    exit
}

[string]$Url = Get-InstanceUrl -Webroot $Webroot

$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $Url

[int]$indexCount = $Indexes.Length
for ($i=0; $i -lt $indexCount; $i++) 
{
    $idxName = $Indexes[$i]

    Show-Progress -Percent $pc -Activity "Rebuilding indexes" -Status $idxName

    Invoke-RemoteScript -ScriptBlock {
        Initialize-SearchIndex -Name "$($using:idxName)" 
    } -Session $session

    [int]$pc = $i / $indexCount * 100
    
    Write-Output "Index $idxName successfully rebuilt"   

    Start-Sleep -Seconds 1
}

Show-Progress -Percent 100 -Activity "Rebuilding indexes" -Status "completed."

Write-Output "."
Show-Message -Fore White -Back Yellow -Text "All the indexes have been successfully rebuilt"
exit
