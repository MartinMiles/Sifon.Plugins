### Name: Kill local process
### Description: Shows a grid with all processes running on a host with an option to terminate them.

#Get-Service | select Name, DisplayName, Status | Out-GridView -Title 'Which process do you want to kill?' -OutputMode Single | Stop-Process -WhatIf
$process = Get-Process |
  #Where-Object MainWindowTitle |
  #Sort-Object -Property Name |
  # important: object clone required
  # Select-Object -Property * |
  Select-Object -Property Name, Id, Path, WorkingSet, PeakWorkingSet, Description |
  Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $i -Force -PassThru |

  Out-GridView -Title 'Please select the process you want terminate' -OutputMode Single 

  If ($process -ne $null)
  {
    [string]$processName = $process.Name
    $UserResponse= [System.Windows.Forms.MessageBox]::Show("Are you sure you want to KILL the process $processName ?" , "Status" , 4)
    if ($UserResponse -eq 'YES') 
    {
        Stop-process -Name $processName
        Write-Output "Process $processName has been terminated."
    }
  }
