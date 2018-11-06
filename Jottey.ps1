<#
.NAME
  Jottey
.SYNOPSIS
  A simple notepad
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO
[System.Windows.Forms.Application]::EnableVisualStyles()

# Globals
$global:InputFile = ""
$global:FilesOpened = 0

#region begin GUI{ 

$Jottey = New-Object System.Windows.Forms.Form
$Jottey.ClientSize = "400,400"
$Jottey.Text = "Jottey"
$Jottey.TopMost = $false
$Jottey.Icon = "icon.ico"

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Multiline = $true
$TextBox.Width = 400
$TextBox.Height = 376
$TextBox.Anchor = "top,right,bottom,left"
$TextBox.Location = New-Object System.Drawing.Point(0, 24)
$TextBox.Font = "Consolas,10"
$TextBox.ScrollBars = "Both"
$TextBox.Add_TextChanged( { TextBoxType $TextBox $EventArgs } )

$Jottey.Controls.Add($TextBox)

$Menu = New-Object System.Windows.Forms.MenuStrip
$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$OpenMenu = New-Object System.Windows.Forms.ToolStripMenuItem

$Menu.Items.AddRange(@($FileMenu))
$Menu.Location = New-Object System.Drawing.Point(0, 0)
$Menu.Name = "Menu"
$Menu.Size = New-Object System.Drawing.Size(400, 24)
$Menu.TabIndex = 0
$Menu.Text = "Menu"

$FileMenu.DropDownItems.AddRange(@($OpenMenu))
$FileMenu.Name = "fileToolStripMenuItem"
$FileMenu.Size = New-Object System.Drawing.Size(35, 20)
$FileMenu.Text = "&File"

$OpenMenu.Name = "openToolStripMenuItem"
$OpenMenu.Size = New-Object System.Drawing.Size(152, 22)
$OpenMenu.Text = "&Open"
$OpenMenu.Add_Click( { OpenMenuClick $OpenMenu $EventArgs} )

$Jottey.Controls.Add($Menu)

#region gui events {
function OpenMenuClick($Sender, $e) {
  $global:InputFile = GetFileName "C:\"
  $InputData = Get-Content $global:InputFile
  $TextBox.Text = $InputData
  
  # Monitor file for changes
  if ($global:FilesOpened -gt 0) {
    Unregister-Event FileChanged
  }
  $folder = Split-Path -Path $global:InputFile
  $fsw = New-Object IO.FileSystemWatcher $folder, $global:InputFile -Property @{IncludeSubdirectories = $false; NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'; } 
  
  Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
    $name = $Event.SourceEventArgs.Name 
    $changeType = $Event.SourceEventArgs.ChangeType 
    $timeStamp = $Event.TimeGenerated 
    Alert "The file '$name' was $changeType at $timeStamp"

    # Refresh file
    $InputData = Get-Content $global:InputFile
    $TextBox.Text = $InputData
  }

  $global:FilesOpened++
}

function TextBoxType($Sender, $e) {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text
  }
  else {
    Alert "No file to save!"
  }
}

function GetFileName($InitialDirectory) {
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
  
  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.InitialDirectory = $InitialDirectory
  $OpenFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileName
}

function Alert($Message) {
  [System.Windows.Forms.MessageBox]::Show($Message)
}

#endregion events }

#endregion GUI }

$Jottey.add_FormClosing( { if ($global:FilesOpened -gt 0) { Unregister-Event FileChanged } })
[void]$Jottey.ShowDialog()