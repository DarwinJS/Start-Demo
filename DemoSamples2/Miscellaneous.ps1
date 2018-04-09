#

# PSH Profiles on your desktop clients should not be run due to their unknown contents
# Your scripts can check for whether -noprofile was used and report it in logs or on screen during script development

#detecting if a PSH profile was loaded:
-not ([bool]([Environment]::GetCommandLineArgs() -like '-noprofile'))

#Setting a variable:
#B
$WasPSProfileUsed = -not ([bool]([Environment]::GetCommandLineArgs() -like '-noprofile'))
Write-Host "Value of `$WasPSProfileUsed: $WasPSProfileUsed"
#/B

#Generating a Message
If ( -not ([bool]([Environment]::GetCommandLineArgs() -like '-noprofile'))) {“Oh no, you used the PS Profile”}

#Challenges with 32-bit Locations
#'  [*] No consistent, single reference for 32-bit locations when executing as:
#'      [A] 32-bit Proc on 32-bit OS (XP, Win7 & Server 2003 and Later)
#'      [B] 32-bit Proc on 64-bit OS (XP, Win7 & Server 2003 and Later)
#'      [C] 64-bit Proc on 64-bit OS (XP, Win7 & Server 2003 and Later)
#
#' It comes into play for everyone:
#'   [*] Windows Explorer Execution (32-bit on 32-bit OS, 64-bit on 64-bit OS)
#'   [*] SCCM 2007 Agents = 32-bit, SCCM 2012 Agents = 64-bit (script execution bitness follows)
#'   [*] XP (usually 32-bit), Win 7 (64-bit or mixed 32/64-bit)
#'   [*] Up to Server 2008 R2 = 32-bit/64-bit, afterward = 64-bit
#'   [*] Send links to scripts in Outlook = 32-bit Script Execution
#'   [*] Embed links in any Office document = 32-bit Script Execution
#
#' Rather than fuss with this each time (after forgetting each time), create your own:

# Some detection methods are "dumbed down" because more sophisticated ones do not work reliably
# in all user contexts (SYSTEM account, machine account) or all OSes or all process Bitnesses
# The three folder variables can be set based on machine architecture.
# A simple way to detect this in all user contexts and in both execution 
# bitnesses back to Windows 7 (e.g. does work in 32-bit proc on 64-bit XP)
#' is to check the existence of the ProgramFiles(x86) environment variable.
#B
if (test-path env:ProgramFiles`(x86`)) {
    $global:DIR_ProgramFilesfor32BitSoftwareSAFE = ${Env:ProgramFiles(x86)}
    $global:DIR_CommonFilesfor32BitSoftwareSAFE = ${Env:CommonProgramFiles(x86)}
    $global:DIR_Systemfor32BitSoftwareSAFE = ${Env:WinDir} + "\SysWOW64"
	} else {
    $global:DIR_ProgramFilesfor32BitSoftwareSAFE = ${Env:ProgramFiles}
    $global:DIR_CommonFilesfor32BitSoftwareSAFE = ${Env:CommonProgramFiles}
    $global:DIR_Systemfor32BitSoftwareSAFE = ${Env:WinDir} + "\System32"
  }
#/B

#For the registry and 64-bit "System32" folder, it is based on our process bitness.  
#The following works for 32 and 64-bit Oses for all user contexts
#B
  if ($env:PROCESSOR_ARCHITECTURE -eq 'x86') {
    $global:DIR_HKLMRegRootfor32BitSoftwareSAFE = "SOFTWARE"
    if (test-path env:ProgramFiles`(x86`)) {
		  $global:DIR_64BitSystem32SAFE = ${Env:WinDir} + "\Sysnative"
    } else {		
		  $global:DIR_64BitSystem32SAFE = ${Env:WinDir} + "\System32"
		}
  } else {
    $global:DIR_HKLMRegRootfor32BitSoftwareSAFE = "SOFTWARE\Wow6432Node"   
    #The next line just provides consistent references on a pure 32-bit OS - if used
		#it points to the 32-bit System32 rather than fail.  This makes it "SAFE" to use all the time.
		$global:DIR_64BitSystem32SAFE = ${Env:WinDir} + "\System32"
  }
#/B

#Checking if Server OS
[bool]((gwmi win32_operatingsystem).ProductType -gt 1)

#Setting a Variable
$IsServer = [bool]((gwmi win32_operatingsystem).ProductType -gt 1)

#Look at a file
#get-content ".\msi.log"

#Look at only the last 100 lines
get-content ".\msi.log" -Tail 100

#Tail An Active File
Get-Content ".\msi2.log" -Tail 50 -Wait

