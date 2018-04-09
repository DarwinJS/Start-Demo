
#   ARP Inventory Advanced
#
#********************************

# Improvements:
#
#'   [*] Allow selective inclusion of: [1] Child updates, [2] Installs hidden from ARP display, [3] KB Updates 
#'   [*] Parse out MSI GUID if it exists in UninstallString registry value
#'   [*] Parse out KB article ID if it exists in parent registry key
#'   [*] Parse out KB update GUID if it exists in parent registry key

# Load up allarps with data
$allarps = Get-ItemProperty hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\*
$allarps += Get-ItemProperty hklm:\software\microsoft\windows\currentversion\uninstall\*
$allarps += Get-ItemProperty hkcu:\software\microsoft\windows\currentversion\uninstall\*
Write-host "Complete Uninstall Unfiltered count: $($allarps.count)"

#  In order to show the exact default view of Programs and Features 
#    of Add Remove Programs we filtered out items that had a parent (child updates) and 
#    items that were hidden using a registry value "SystemComponent" and items that had
#'    no display name (usually KB updates)
#
#' Let's revise the script to make these filters optional.
# 
#  To do that we'll need to build the PowerShell filter code in a variable and then 
#'   execute it.
# Lets set variables to control what is included:
$IncludeKBUpdates = $true
$IncludeUpdates = $true
$IncludeSystemComponents = $true

# When placing PowerShell code in to a variable all PowerShell special characters 
# must be escaped with the backtick character (`):
	$filter=$null
	if (-not $IncludeKBUpdates) {$filter = "`$_.DisplayName -ne `$Null"}
  if (-not $IncludeChildUpdates) {if($filter) {$filter += " -and "}; $filter += "!`$_.ParentKeyName"}
  if (-not $IncludeHiddenItems) {if($filter) {$filter += " -and "}; $filter += "`$_.SystemComponent -ne 1"}

# $Filter contains the filter built above
$commandstring = "`$allarps | where-object {$filter} | sort-object DisplayName, DisplayVersion -unique"

# Invoke-Expression is how to execute code stored in a variable
$filteredarps = Invoke-Expression $commandstring

#Output to gridview (now includes additional items it previously did not)
$filteredarps | select-object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString, PSParentPath | out-gridview -Title "Add Remove Programs View: $($filteredarps.count) Items"

# There are several other pieces of information embedded in the ARP registry keys:
#'    [*] MSI Product code in UninstallString (e.g. msiexec /x {ProductCodeGUID}
#'    [*] KB number in Parent Registry Key name (e.g. <GUID>.KB28383)
#'    [*] KB Update GUID in Parent Registry Key name (e.g. <GUID>.KB28383)
#
#' This can be parsed with regular expression and set as object properties.
#
#RECIPE ALERT: The next code shows how to add properties to an object by parsing other properties
#  in the same object.
  $allarps | foreach-Object { `
	  if ($_.UninstallString -match '(?<GUIDFromUninstallString>[0-9a-fA-F{}-]{38})'	) { `
		Add-Member -InputObject $_ –MemberType NoteProperty –Name GUIDFromUninstallString -Value ([regex]::match($_.UninstallString,'(?<GUIDFromUninstallString>[0-9a-fA-F{}-]{38})') | foreach {$_.groups["GUIDFromUninstallString"].value})} `
		if ($_.PSChildName -match '(?<KBGUIDFromKeyName>[0-9a-fA-F{}-]{38})\.KB'	) { `
		Add-Member -InputObject $_ –MemberType NoteProperty –Name KBGUIDFromKeyName -Value ([regex]::match($_.PSChildName,'(?<KBGUIDFromKeyName>[0-9a-fA-F{}-]{38})\.KB') | foreach {$_.groups["KBGUIDFromKeyName"].value})}` 
		if ($_.PSChildName -match '\.(?<KBIDFromKeyName>KB[0-9]{2,8})'	) { `
		Add-Member -InputObject $_ –MemberType NoteProperty –Name KBIDFromKeyName -Value ([regex]::match($_.PSChildName,'\.(?<KBIDFromKeyName>KB[0-9]{2,8})') | foreach {$_.groups["KBIDFromKeyName"].value})} `
		}

#Now we'll refilter allarps and display it as a grid:
$filteredarps = Invoke-Expression $commandstring
$filteredarps | select-object DisplayName, DisplayVersion, Publisher, InstallDate, GUIDFromUninstallString, KBGUIDFromKeyName, KBIDFromKeyName, UninstallString, PSParentPath | out-gridview -Title "Installed Software: $($filteredarps.count) Items."

#  Additional Items included in the Production Ready version of this code: 
#'    [*] Implemented as a set of functions
#'    [*] Enhanced error checking of contents in retrieved registry keys
#'    [*] Works whether script is running as 32-bit or 64-bit.

