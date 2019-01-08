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

#region gui events {

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

function TextBoxType() {
  if ($global:InputFile -ne "") {
    Set-Content $global:InputFile $TextBox.Text

    $Time = Get-Date -F "HH:mm:ss"
    $StatusBarPanel_AutoSave.Text = "Last Saved: $Time"
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