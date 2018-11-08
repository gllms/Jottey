<#
.NAME
  Jottey
.SYNOPSIS
  A simple notepad
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Globals
$global:InputFile = ""
$global:FilesOpened = 0

#region begin GUI{ 

$Jottey = New-Object System.Windows.Forms.Form
$Jottey.ClientSize = "400,400"
$Jottey.Text = "Jottey"
$Jottey.TopMost = $false
$Jottey.Icon = ".\icon.ico"

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
$FileMenuIcon = (get-item ".\img\file.png")
$FileMenu.Image = [System.Drawing.Image]::Fromfile($FileMenuIcon)

$OpenMenu.Name = "openToolStripMenuItem"
$OpenMenu.Size = New-Object System.Drawing.Size(152, 22)
$OpenMenu.Text = "&Open"
$OpenMenuIcon = (get-item ".\img\open.png")
$OpenMenu.Image = [System.Drawing.Image]::Fromfile($OpenMenuIcon)
$OpenMenu.Add_Click( { OpenMenuClick $OpenMenu $EventArgs} )

$Jottey.Controls.Add($Menu)

#region gui events {
function OpenMenuClick($Sender, $e) {
  $global:InputFile = GetFileName "C:\"
  $InputData = Get-Content $global:InputFile -Raw
  $TextBox.Text = $InputData
  
  # Monitor file for changes
  $timer=New-Object System.Windows.Forms.Timer
  $timer.Interval = 1000
  $timer.add_Tick({
    if (-Not ($global:InputFile -eq "")) {
      if (-Not ($TextBox.Text -eq (Get-Content $global:InputFile -Raw))) {
        # Get cursor position
        $CursorPos = $TextBox.SelectionStart
        $SelectionLength = $TextBox.SelectionLength

        $TextBox.Text = Get-Content $global:InputFile -Raw

        # Reset cursor position
        $TextBox.Select($CursorPos, $SelectionLength)
      }
    }
  })
  $timer.Start()

  $global:FilesOpened++
}

function TextBoxType($Sender, $e) {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text -Encoding UTF8
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

# $Jottey.add_FormClosing( { if ($global:FilesOpened -gt 0) { Unregister-Event FileChanged } })
[void]$Jottey.ShowDialog()
