#region Script Settings
#<ScriptSettings xmlns="http://tempuri.org/ScriptSettings.xsd">
#  <ScriptPackager>
#    <process>powershell.exe</process>
#    <arguments />
#    <extractdir>%TEMP%</extractdir>
#    <files />
#    <usedefaulticon>true</usedefaulticon>
#    <showinsystray>false</showinsystray>
#    <altcreds>false</altcreds>
#    <efs>true</efs>
#    <ntfs>true</ntfs>
#    <local>false</local>
#    <abortonfail>true</abortonfail>
#    <product />
#    <version>1.0.0.1</version>
#    <versionstring />
#    <comments />
#    <company />
#    <includeinterpreter>false</includeinterpreter>
#    <forcecomregistration>false</forcecomregistration>
#    <consolemode>false</consolemode>
#    <EnableChangelog>false</EnableChangelog>
#    <AutoBackup>false</AutoBackup>
#    <snapinforce>false</snapinforce>
#    <snapinshowprogress>false</snapinshowprogress>
#    <snapinautoadd>2</snapinautoadd>
#    <snapinpermanentpath />
#    <cpumode>1</cpumode>
#    <hidepsconsole>false</hidepsconsole>
#  </ScriptPackager>
#</ScriptSettings>
#endregion

#Region testing
#   Packaging Event 2013
#
#********************************

# Checking for admin permissions:
#
#'   Check the current process Admin Token not Administrators group membership because:
#
#'     [*] User IDs in administrators, but process is not elevated
#'     [*] System Account has admin, but is not in Administrators
#'     [*] Nested groups may give admin but are slow to enumerate, can be enumerated offline
#EndRegion

#'List Groups and Group SIDs:
([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups

#'List process token SIDS and look for "S-1-5-32-544"
(([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#'Modifications to make it a True / False test
((([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") | select value).value -eq "S-1-5-32-544"

#'Cleaner, quicker way to make it a True / False test
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

#'Setting a variable prevents recalling code throughout the process:
$IsProcElevated = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
Write-Host $IsProcElevated
