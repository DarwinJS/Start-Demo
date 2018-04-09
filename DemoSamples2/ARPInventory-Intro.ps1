
#   ARP Inventory 1
#
#********************************

# Problems Addressed:
#  => Challenging to obtain: 
#
#'   [*] a complete list of installed software
#'   [*] check if a specific application (possibly a specific version) is installed
#'   [*] retreive and compare the version of an installed application
#    [*] get the exact list of software displayed in Add/Remove Programs or Programs 
#'       and Features

#RECIPE ALERT: Following line enumerates all registry sub-keys into objects with 
#              each value being an object property:
$allarps = Get-ItemProperty hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\*
Write-host "32-bit Uninstall Unfiltered Enum: $($allarps.count)" 

#Do the same for 64-bit Registry Key (no "wow6432node" level) =>
#RECIPE ALERT: Below code shows how to accumulate objects from multiple sources in one 
#              variable (collection) using the append operator "+="
$allarps += Get-ItemProperty hklm:\software\microsoft\windows\currentversion\uninstall\*
Write-host "32-bit and 64-bit Uninstall Unfiltered Enum: $($allarps.count)" 

#Do the same for Per-User
$allarps += Get-ItemProperty hkcu:\software\microsoft\windows\currentversion\uninstall\*
Write-host "Complete Uninstall Unfiltered count: $($allarps.count)"

#RECIPE ALERT: The following filter is the secret sauce to getting your inventory to 
#              match ARP / Programs and Features
#Filter hidden (SystemComponent=1) and Updates (ParentKey exists or DisplayName blank)
$filteredarps = $allarps | where-object {$_.DisplayName -ne $Null -and !$_.ParentKeyName -and $_.SystemComponent -ne 1} |  sort-object DisplayName, DisplayVersion -unique
Write-host "Filtered count: $($filteredarps.count)"

#
#Output to gridview
$filteredarps | select-object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString, PSParentPath | out-gridview -Title "Installed Software: $($filteredarps.count) Items."

#
#Output to file - add computername and suppress column headings so files can be 
#                 concatenated via copy command
#RECIPE ALERT: Below code shows how to export to CSV and skip column headings
$CompName = $env:computername
$TempPath = $env:temp
$filteredarps | % { Add-Member -InputObject $_ -MemberType NoteProperty -Name ComputerName -Value $env:computername ; $_ } | select-object ComputerName, DisplayName, DisplayVersion, Publisher, UninstallString, PSParentPath |  ConvertTo-Csv | Select -Skip 2 | Out-File "$tempPath\$CompName-ARPINV.csv" -Force
