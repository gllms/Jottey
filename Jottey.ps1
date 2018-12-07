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

$InitialDirectory = "C:\"

$global:OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$global:OpenFileDialog.InitialDirectory = $InitialDirectory
$global:OpenFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"

$global:SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$global:SaveFileDialog.InitialDirectory = $InitialDirectory
$global:SaveFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*"

#region begin GUI{ 

$Jottey = New-Object System.Windows.Forms.Form
$Jottey.ClientSize = "400,400"
$Jottey.Text = "Jottey"
$Jottey.TopMost = $false
$Jottey.Icon = "img/icon.ico"
$Jottey.Add_Load( { FormLoad $TextBox $EventArgs } )

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Multiline = $true
$TextBox.AcceptsTab = $true
$TextBox.Width = 400
$TextBox.Height = 354
$TextBox.Anchor = "top,right,bottom,left"
$TextBox.Location = New-Object System.Drawing.Point(0, 24)
$TextBox.Font = "Consolas,10"
$TextBox.ScrollBars = "Both"
$TextBox.Add_KeyUp( { TextBoxType $TextBox $EventArgs } )
$TextBox.Add_Click( { TextBoxType $TextBox $EventArgs } )
$TextBox.Add_MouseLeave( { TextBoxType $TextBox $EventArgs } )

$Jottey.Controls.Add($TextBox)

$Menu = New-Object System.Windows.Forms.MenuStrip
$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$OpenMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$SaveAsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$AboutMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$EditMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$SettingsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$FontMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$SelectAllMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$UndoMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$CutMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$CopyMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$PasteMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$DeleteMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$Seperator = New-Object System.Windows.Forms.ToolStripSeparator

$Menu.Items.AddRange(@($FileMenu; $EditMenu; $SettingsMenu))
$Menu.Location = New-Object System.Drawing.Point(0, 0)
$Menu.Name = "Menu"
$Menu.Size = New-Object System.Drawing.Size(400, 24)
$Menu.TabIndex = 0
$Menu.Text = "Menu"

$FileMenu.DropDownItems.AddRange(@($OpenMenu; $SaveAsMenu; $AboutMenu))
$FileMenu.Name = "fileToolStripMenuItem"
$FileMenu.Size = New-Object System.Drawing.Size(35, 20)
$FileMenu.Text = "&File"

$OpenMenu.Name = "openToolStripMenuItem"
$OpenMenu.Size = New-Object System.Drawing.Size(152, 22)
$OpenMenu.Text = "&Open"
$OpenMenu.Add_Click( { OpenMenuClick $OpenMenu $EventArgs} )
$OpenMenu.ShortCutKeys = "Control+O"

$SaveAsMenu.Name = "saveAsToolStripMenuItem"
$SaveAsMenu.Size = New-Object System.Drawing.Size(152, 22)
$SaveAsMenu.Text = "&Save As..."
$SaveAsMenu.Add_Click( { SaveAsMenuClick $SaveAsMenu $EventArgs} )
$SaveAsMenu.ShortCutKeys = "Control+S"

$AboutMenu.Name = "aboutToolStripMenuItem"
$AboutMenu.Size = New-Object System.Drawing.Size(269, 22)
$AboutMenu.Text = "&About"
$AboutMenu.Add_Click( { AboutMenuClick $AboutMenu $EventArgs} )

$EditMenu.DropDownItems.AddRange(@($UndoMenu; New-Object $Seperator; $CutMenu; $CopyMenu; $PasteMenu; $DeleteMenu; New-Object $Seperator; $SelectAllMenu))
$EditMenu.Name = "editToolStripMenuItem"
$EditMenu.Size = New-Object System.Drawing.Size(35, 20)
$EditMenu.Text = "&Edit"

$SelectAllMenu.Name = "selectAllToolStripMenuItem"
$SelectAllMenu.Size = New-Object System.Drawing.Size(152, 22)
$SelectAllMenu.Text = "Select &All"
$SelectAllMenu.Add_Click( { SelectAllMenuClick $OpenMenu $EventArgs} )
$SelectAllMenu.ShortCutKeys = "Control+A"

$UndoMenu.Name = "undoToolStripMenuItem"
$UndoMenu.Size = New-Object System.Drawing.Size(152, 22)
$UndoMenu.Text = "&Undo"
$UndoMenu.Add_Click( { $TextBox.Undo() } )
$UndoMenu.ShortCutKeys = "Control+Z"

$CutMenu.Name = "cutToolStripMenuItem"
$CutMenu.Size = New-Object System.Drawing.Size(152, 22)
$CutMenu.Text = "Cu&t"
$CutMenu.Add_Click( { $TextBox.Cut() } )
$CutMenu.ShortCutKeys = "Control+X"

$CopyMenu.Name = "copyToolStripMenuItem"
$CopyMenu.Size = New-Object System.Drawing.Size(152, 22)
$CopyMenu.Text = "&Copy"
$CopyMenu.Add_Click( { $TextBox.Copy() } )
$CopyMenu.ShortCutKeys = "Control+C"

$PasteMenu.Name = "pasteToolStripMenuItem"
$PasteMenu.Size = New-Object System.Drawing.Size(152, 22)
$PasteMenu.Text = "&Paste"
$PasteMenu.Add_Click( { $TextBox.Paste() } )
$PasteMenu.ShortCutKeys = "Control+V"

$DeleteMenu.Name = "deleteToolStripMenuItem"
$DeleteMenu.Size = New-Object System.Drawing.Size(152, 22)
$DeleteMenu.Text = "&Delete"
$DeleteMenu.Add_Click( { $TextBox.Text = $TextBox.Text.Remove($TextBox.SelectionStart, $TextBox.SelectionLength) } )
$DeleteMenu.ShortCutKeys = "Del"

$SettingsMenu.DropDownItems.AddRange(@($FontMenu))
$SettingsMenu.Name = "settingsToolStripMenuItem"
$SettingsMenu.Size = New-Object System.Drawing.Size(35, 20)
$SettingsMenu.Text = "&Settings"

$FontMenu.Name = "fontToolStripMenuItem"
$FontMenu.Size = New-Object System.Drawing.Size(152, 22)
$FontMenu.Text = "Fo&nt"
$FontMenu.Add_Click( { FontMenuClick $FontMenu $EventArgs })

$Jottey.Controls.Add($Menu)

$StatusBar = New-Object System.Windows.Forms.StatusBar
$StatusBarPanel = New-Object System.Windows.Forms.StatusBarPanel
$StatusBarPanel.Width = 70
$StatusBarPanel_AutoSave = New-Object System.Windows.Forms.StatusBarPanel
$StatusBarPanel_AutoSave.Width = 115
$StatusBarPanel.Text = "Ln 1, Col 1"
$StatusBar.ShowPanels = $true
$StatusBar.Panels.Add($StatusBarPanel)
$StatusBar.Panels.Add($StatusBarPanel_AutoSave)

$Jottey.Controls.Add($StatusBar)

#region gui events {
function FormLoad($Sender, $e) {
  if (Test-Path ".\text.tmp") {
    $TextBox.Text = Get-Content ".\text.tmp"
  }
}

function OpenMenuClick($Sender, $e) {
  if ($global:OpenFileDialog.ShowDialog() -eq "OK") {
    $global:InputFile = $global:OpenFileDialog.FileName
    $InputData = Get-Content $global:InputFile
    $TextBox.Text = $InputData
    $Jottey.Text = $global:InputFile + " - Jottey"
  }
}

function SaveAsMenuClick($Sender, $e) {
  if ($global:SaveFileDialog.ShowDialog() -eq "OK") {
    $global:InputFile = $global:SaveFileDialog.FileName
    $Jottey.Text = $global:InputFile + " - Jottey"
    if (Test-Path -Path ".\text.tmp") {
      Remove-Item -Path ".\text.tmp"
    }
  }
}

function SelectAllMenuClick($Sender, $e) {
  $TextBox.SelectAll()
  TextBoxType
}

function TextBoxType($Sender, $e) {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text

    $Time = Get-Date -F "HH:mm:ss"
    $StatusBarPanel_AutoSave.Text = "Last Saved: $Time"
  } elseif (Test-Path -Path ".\text.tmp") {
    Set-Content ".\text.tmp" $TextBox.Text 
  } else {
    $TextBox.Text | Out-File ".\text.tmp"
  }

  if($TextBox.SelectionLength){
    $StatusBarPanel.Text = "Chars: " + ($TextBox.SelectedText).Length
  }
  else{
    $s = $TextBox.SelectionStart
    $y = $TextBox.GetLineFromCharIndex($s) + 1
    $x = ($s - $TextBox.GetFirstCharIndexOfCurrentLine() + 1)
    $StatusBarPanel.Text = "Ln: $y, Col: $x"
  }
}

function AboutMenuClick(){
  $Buttons=[System.Windows.Forms.MessageBoxButtons]::OK;
  $Message = [string]@'
  Jottey. 
  Simple plain text editor completely written in PowerShell.
  Saves files automatically.

  Contribute - https://github.com/gllms/Jottey
  
  MIT License - https://github.com/gllms/Jottey/blob/master/LICENSE.txt

  Copyright (c) 2018 gllms
'@

  [System.Windows.Forms.MessageBox]::Show($Message, "About", $Buttons);
}

function FontMenuClick($Sender, $e) {
  $FontDialog = New-Object System.Windows.Forms.FontDialog
  $FontDialog.ShowColor = $true;
  $FontDialog.ShowEffects = $true;
  $FontDialog.ShowApply = $true;

  $FontDialog.Font = $TextBox.Font
  $FontDialog.Color = $TextBox.ForeColor

  if($FontDialog.ShowDialog() -ne "Cancel" ) {
     $TextBox.Font = $FontDialog.Font
     $TextBox.ForeColor = $FontDialog.Color
  }
}

function Alert($Message) {
  [System.Windows.Forms.MessageBox]::Show($Message)
}

#endregion events }

#endregion GUI }

[void]$Jottey.ShowDialog()