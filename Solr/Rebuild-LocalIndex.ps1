### Name: Rebuild indexes on local machine
### Description: Rebilds indexes via SPE remoting - due to GUI works on local machines only
### Compatibility: Sifon 0.95

param(
    [string]$Webroot,
    [string]$AdminUsername,
    [string]$AdminPassword
)

Function Get-InstanceUrl {

    Import-Module WebAdministration
    $sites = Get-ChildItem -Path IIS:\Sites

    $dict = New-Object 'System.Collections.Generic.List[String[]]'
    Foreach ($site in $sites)
    {
        $path = $site.PhysicalPath.ToString()

        if($Webroot.TrimEnd('\') -eq $path)
        {
            $bindings = [PowerShell]::Create().AddCommand("Get-WebBinding"). `
                AddParameter("Name", $site.Name).Invoke()

            $bindings | ForEach-Object {
                [string[]]$arr = $_.protocol,$_.bindingInformation.Split(':')[2]
                $dict.Add($arr)
            }
        }
    }

    If($dict.Count -gt 0)
    {
        $Url = $dict[0][0] + "://" + $dict[0][1]
        return $Url 
    }
}


[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBox.FormattingEnabled = $true
$comboBox.Location =  New-Object System.Drawing.Point(15, 45)
$comboBox.Name = "comboBox1"
$comboBox.Size =  New-Object System.Drawing.Size(350, 22)
$comboBox.TabIndex = 0


[string]$Url = Get-InstanceUrl
$session = New-ScriptSession -Username $AdminUsername -Password $AdminPassword -ConnectionUri $Url
Write-Output "Sifon-MuteOutput"
    $indexes = Invoke-RemoteScript -ScriptBlock {
        Get-SearchIndex | % { $_.Name }
    } -Session $session
Write-Output "Sifon-UnmuteOutput"

$ALL_INDEXES = "== all the indexes =="
foreach($index in $indexes)
{
    $comboBox.Items.add($index)
}
If($comboBox.Items.Count -gt 0)
{
    $comboBox.Items.Insert(0, $ALL_INDEXES)
    $comboBox.SelectedIndex = 0;
}

$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(12, 29)
$label.Name = "label1"
$label.Size = New-Object System.Drawing.Size(36, 13)
$label.TabIndex = 1
$label.Text = "Index:"

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(380, 44)
$button.Name = "button2"
$button.Size = New-Object System.Drawing.Size(75, 23)
$button.TabIndex = 2
$button.Text = "Rebuild"
$button.UseVisualStyleBackColor = $true
$button.DialogResult = [System.Windows.Forms.DialogResult]::OK


$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.SuspendLayout()
$groupBox.Controls.Add($button)
$groupBox.Controls.Add($comboBox)
$groupBox.Controls.Add($label)
$groupBox.Location = New-Object System.Drawing.Point(12, 12)
$groupBox.Name = "groupBox1";
$groupBox.Size = New-Object System.Drawing.Size(472, 102)
$groupBox.TabIndex = 2
$groupBox.TabStop = $false
$groupBox.Text = "Sitecore indexes"

$form = New-Object System.Windows.Forms.Form
$form.ClientSize = New-Object System.Drawing.Size(407, 390)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
$form.Name = "Indexes"
$form.Text = "Rebuild indexes"
$form.ClientSize = New-Object System.Drawing.Size(498, 129)


$form.AcceptButton = $button
$form.Controls.Add($groupBox)

If($form.showdialog() -eq [System.Windows.Forms.DialogResult]::OK)
{
    if($comboBox.Text -ne $ALL_INDEXES)
    {
        $indexes = $comboBox.Text
    }

    foreach($index in $indexes)
    {
        Invoke-RemoteScript -ScriptBlock {
            Initialize-SearchIndex -Name "$($using:index)" 
        } -Session $session

        Write-Output "Index $index successfully rebuilt"
    }

    Write-Output "#COLOR:GREEN# All the indexes successfully rebuilt"
}