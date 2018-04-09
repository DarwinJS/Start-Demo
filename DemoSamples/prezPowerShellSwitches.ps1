#BI
$WindowTitle = "PowerShell.exe Switches"
$NoBanner = $True
#/B

#
# Picking the Correct PowerShell.exe Command Line Options:
#
#CBH   PROBLEM 1: EXECUTION POLICY CONFIGURATION 
#
#'CY     [*] Set on each machine *before* running any scripts
#'CY     [*] Set individually for both 32-bit and 64-bit PowerShell.exe
#CY'     [*] Execution policy can be set at 5 different levels
#
#CR  More Info:
#CB  http://blogs.msdn.com/b/powershell/archive/2008/09/30
#CB   /powershell-s-security-guiding-principles.aspx
#
#'       Demo Time...
#CLR
#CBH' Wrap Up:

#CY     [*] powershell.exe -Command "write-host 'Hi'"
#'CR         No concern about execution policy, no file at client.

#CY     [*] powershell.exe -File filename.ps1
#'CR         Most reliable way to execute scripts.

#CY     [*] powershell.exe -ExecutionPolicy bypass 
#'CR         Run script from anywhere with no restrictions.

#CY     [*] powershell.exe -NoProfile 
#'CR         Skip PSH profiles to avoid errors, overrides, junk.

#CY     [*] powershell.exe -Version 2.0
#'CR         Test script on PSH version 2, older version for compatibility.

#CY     [*] powershell.exe -WindowStyle Hidden
#'CR         Prevents users from killing script using "X" on console.

#CY     [*] powershell.exe -NoExit
#'CR         Prevent exiting (for debugging).