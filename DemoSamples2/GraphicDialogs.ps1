#[System.Windows.Forms.MessageBox]::Show('Message box contents', 'Window Title', 'YesNoCancel', 'Warning')

function Write-MessageBox {
<#
.SYNOPSIS
  Displays a simple messag box
.DESCRIPTION
  Uses .NET class to display a simple message box.
.PARAMETER Message
   Text of the Message.
.PARAMETER WindowTitle
   Title of the Window.
.PARAMETER Buttons
   Which buttons to display.
.PARAMETER Icon
   Which messag box icon to display
.EXAMPLE
  Set-OasisOutage
.EXAMPLE
  Set-OasisOutage -OutageMinutes "120"
.EXAMPLE
  Set-OasisOutage -OutageMinutes "120" -OutageOperation "MODIFY"
.EXAMPLE
  Set-OasisOutage -OutageMinutes "120" -TargetNode "ABCComputer"
.EXAMPLE
  Set-OasisOutage -Program "SomethingOtherThanThisScript" -TargetNode "ABCComputer"
.EXAMPLE
  Set-OasisOutage -OutageOperation "DELETE"
.NOTES
  Author: Darwin Sanoy
  Modified: 10/5/2013
  Unit Test: Only if explicitly called.
  Test Verification: Run function interactively and watch for message box.
	Last Tested: 10/5/2013 by Darwin Sanoy
#>  
[CmdletBinding()]
param (
	[parameter(Mandatory=$True)][string]$MessageText,
	[parameter(Mandatory=$True)][string]$WindowTitle,
	[parameter(Mandatory=$False)][string][ValidateSet("OK","OKCancel", "YesNo", "YesNoCancel", "AbortRetryIgnore", "RetryCancel")]$Buttons="OK",
	[parameter(Mandatory=$False)][string][ValidateSet("Asterisk","Error","Exclamation","Hand","Information","None","Question","Stop","Warning")]$Icon="None",	
	[parameter(Mandatory=$False)][string][ValidateSet("OK","OKCancel", "YesNo", "YesNoCancel", "AbortRetryIgnore", "RetryCancel")]$DefaultButton="OK"
) 

  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
  [System.Windows.Forms.MessageBox]::Show($MessageText, $WindowTitle, $Buttons, $Icon)
}

$Response = Write-MessageBox "This is the Message" "Window Title" -Buttons "YesNo"
Write-Host $Response