#Get-ARPInstalledSoftware
#Darwin Sanoy
#Version = 2.0

# v1.4 Update - can now Include Updates and/or System Components - to be used in psdeploylibrary.ps1 for checking if specific items are installed
# v2.0 Update - implemented core functionality as a function for deployment template, 
#               function takes: -IncludeHiddenItems (SystemComponent)
#                               -IncludeChildUpdates (items with parent name), 
#                               -IncludeKBUpdates (usually have no displayname)
#               function parses: - MSI GUID (or any guid) from UninstallString key, KBGUID, KBID (KB article ID)
#               function automatically handles running in 32-bit on 64-bit Windows
#             - Grid view output includes total number of items in the title bar
#             - Script level parameter -UploadFolder:\\the\folder\name allows overriding default upload location on command line

Function Get-ARPInstalledSoftware {

[CmdletBinding()]
param (
		# Whether to include hidden items
    [parameter(Mandatory=$false)][switch]$IncludeHiddenItems,
  
		# Whether to include Child Updates
    [parameter(Mandatory=$false)][switch]$IncludeChildUpdates,
    
		# Whether to include KB Updates
    [parameter(Mandatory=$false)][switch]$IncludeKBUpdates,
    
    # Pickup any additional unknown parameters (prevents errors for over specification)
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromRemainingArguments=$True)][string[]]$AdditionalArgs
    
    )

	#Grab Native Bitness
	$allarps = Get-ItemProperty hklm:\software\microsoft\windows\currentversion\uninstall\*

	#Grab Per-User if it exists
	if (Test-Path hkcu:\software\microsoft\windows\currentversion\uninstall) {
	  $allarps += Get-ItemProperty hkcu:\software\microsoft\windows\currentversion\uninstall\*
		}

	#Grab Additional Bitness on 64-bit Windows
	if (${env:\ProgramFiles(x86)} -ne $null) {
			#We are on 64-bit
		
			# Using the following aliases with a code block will return the object stream results into the current script
	  	Set-Alias Invoke-64bitExpressionFrom32bitProc "$env:windir\sysnative\WindowsPowerShell\v1.0\powershell.exe"
      Set-Alias Invoke-32bitExpressionFrom64bitProc "$env:windir\syswow64\WindowsPowerShell\v1.0\powershell.exe"

			if ($env:processor_architecture -eq "x86") {
				# but running in a 32-bit process
				$allarps += Invoke-64bitExpressionFrom32bitProc { Get-ItemProperty hklm:\software\microsoft\windows\currentversion\uninstall\* }
			} else {
				$allarps += Get-ItemProperty hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\*
		}
	}

	#filter ARPS to match screen view

  $allarps | % { 
	  if ($_.UninstallString -match '(?<GUIDFromUninstallString>[0-9a-fA-F{}-]{38})'	) {
		Add-Member -InputObject $_ –MemberType NoteProperty –Name GUIDFromUninstallString -Value ([regex]::match($_.UninstallString,'(?<GUIDFromUninstallString>[0-9a-fA-F{}-]{38})') | foreach {$_.groups["GUIDFromUninstallString"].value})}
		if ($_.PSChildName -match '(?<KBGUIDFromKeyName>[0-9a-fA-F{}-]{38})\.KB'	) {
		Add-Member -InputObject $_ –MemberType NoteProperty –Name KBGUIDFromKeyName -Value ([regex]::match($_.PSChildName,'(?<KBGUIDFromKeyName>[0-9a-fA-F{}-]{38})\.KB') | foreach {$_.groups["KBGUIDFromKeyName"].value})}
		if ($_.PSChildName -match '\.(?<KBIDFromKeyName>KB[0-9]{2,8})'	) {
		Add-Member -InputObject $_ –MemberType NoteProperty –Name KBIDFromKeyName -Value ([regex]::match($_.PSChildName,'\.(?<KBIDFromKeyName>KB[0-9]{2,8})') | foreach {$_.groups["KBIDFromKeyName"].value})}
		}

  #Debug code - includes duplicates:
	#$AllArps | select-object DisplayName, DisplayVersion, Publisher, UninstallString, GUIDFromUninstallString, KBGUIDFromKeyName, KBIDFromKeyName, PSParentPath | out-gridview -Title "DEGUB EVERYTHING in The Registry (including hidden, child patches and KB patches): $($allarps.count) Items"

	$filter=$null
	if (-not $IncludeKBUpdates) {$filter = "`$_.DisplayName -ne `$Null"}
  if (-not $IncludeChildUpdates) {if($filter) {$filter += " -and "}; $filter += "!`$_.ParentKeyName"}
  if (-not $IncludeHiddenItems) {if($filter) {$filter += " -and "}; $filter += "`$_.SystemComponent -ne 1"}

  $commandstring = "`$allarps | "
	if ($filter) { $commandstring += "where-object {$filter} | "}
	$commandstring +=  "sort-object DisplayName, DisplayVersion, GUIDFromUninstallString, KBGUIDFromKeyName, KBIDFromKeyName -unique"

  $filteredarps = Invoke-Expression $commandstring

	return $filteredarps
}
