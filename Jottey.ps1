<#
.NAME
  Jottey
.SYNOPSIS
  A simple notepad
#>

Add-Type -AssemblyName PresentationFramework
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

#Build the GUI
[xml]$xaml = Get-Content -Path .\Form.xaml

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load( $reader )
$Window.Add_Loaded( {
    if (Test-Path ".\text.tmp") {
      $TextBox.Text = Get-Content ".\text.tmp" -Raw
    }
  })
$Window.Input

$TextBox = $Window.FindName("TextBox")
$TextBox.Add_KeyUp({ TextBoxType })
$TextBox.Add_MouseLeftButtonUp({ TextBoxType })
$TextBox.Add_SelectionChanged({ TextBoxType })

$StatusBarPanel = $Window.FindName("StatusBarPanel")

$Window.FindName("OpenMenu").Add_Click({ OpenMenuClick })
$Window.FindName("SaveAsMenu").Add_Click({ SaveAsMenuClick })
$Window.FindName("AboutMenu").Add_Click({ AboutMenuClick })
$Window.FindName("UndoMenu").Add_Click({ $TextBox.Undo() })
$Window.FindName("RedoMenu").Add_Click({ $TextBox.Redo() })
$Window.FindName("CutMenu").Add_Click({ $TextBox.Cut() })
$Window.FindName("CopyMenu").Add_Click({ $TextBox.Copy() })
$Window.FindName("PasteMenu").Add_Click({ $TextBox.Paste() })
$Window.FindName("DeleteMenu").Add_Click({ $TextBox.Text = $TextBox.Text.Remove($TextBox.SelectionStart, $TextBox.SelectionLength) })
$Window.FindName("SelectAllMenu").Add_Click({ $TextBox.SelectAll(); TextBoxType })
$Window.FindName("FontMenu").Add_Click({ FontMenuClick })

#region gui events {

function OpenMenuClick($Sender, $e) {
  if ($global:OpenFileDialog.ShowDialog() -eq "OK") {
    $global:InputFile = $global:OpenFileDialog.FileName
    $InputData = Get-Content $global:InputFile
    $TextBox.Text = $InputData
    $Window.Title = $global:InputFile + " - Jottey"
  }
}

function SaveAsMenuClick($Sender, $e) {
  if ($global:SaveFileDialog.ShowDialog() -eq "OK") {
    if ((Test-Path -Path ".\text.tmp") -and ($global:InputFile -eq "")) {
      Remove-Item -Path ".\text.tmp"
    }
    $global:InputFile = $global:SaveFileDialog.FileName
    $Window.Title = $global:InputFile + " - Jottey"
  }
}

function SelectAllMenuClick($Sender, $e) {
  $TextBox.SelectAll()
  TextBoxType
}

function TextBoxType() {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text

    $Time = Get-Date -F "HH:mm:ss"
    $StatusBarPanel.Text = "Last Saved: $Time"
  } elseif (Test-Path -Path ".\text.tmp") {
    Set-Content ".\text.tmp" $TextBox.Text 
  } else {
    $TextBox.Text | Out-File ".\text.tmp"
  }

  if ($TextBox.SelectionLength) {
    $StatusBarPanel.Text = "Chars: " + ($TextBox.SelectedText).Length
  }
  else {
    $y = $TextBox.GetLineIndexFromCharacterIndex($TextBox.CaretIndex);
    $x = $TextBox.CaretIndex - $TextBox.GetCharacterIndexFromLineIndex($y);
    $StatusBarPanel.Text = "Ln: " + ($y + 1) + ", Col: " + ($x + 1);
  }
}

function AboutMenuClick() {
  $Buttons = [System.Windows.Forms.MessageBoxButtons]::OK;
  $Message = [string]@'
  Jottey. 
  Simple plain text editor completely written in PowerShell.
  Saves files automatically.

  Contribute - https://github.com/gllms/Jottey
  
  MIT License - https://github.com/gllms/Jottey/blob/master/LICENSE.txt

  Copyright (c) 2019 gllms
'@

  [System.Windows.Forms.MessageBox]::Show($Message, "About", $Buttons);
}

function FontMenuClick($Sender, $e) {
  $FontDialog = New-Object System.Windows.Forms.FontDialog
  $FontDialog.ShowColor = $true;
  $FontDialog.ShowEffects = $true;
  $FontDialog.ShowApply = $true;

  $FontDialog.Font = $TextBox.FontFamily
  $FontDialog.Color = $TextBox.Foreground

  if ($FontDialog.ShowDialog() -ne "Cancel" ) {
    $TextBox.Font = $FontDialog.Font
    $TextBox.ForeColor = $FontDialog.Color
  }
}

function Alert($Message) {
  [System.Windows.Forms.MessageBox]::Show($Message)
}

#endregion events }

#endregion GUI }

[void]$Window.ShowDialog()