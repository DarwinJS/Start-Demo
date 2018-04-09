<#
      
      ARPInventory Using A Production Ready Function
      
   ********************************	
#>

#BI
[CmdletBinding()] 
param ( 
    # Whether to export to CSV file rather than screen output
    [parameter(Mandatory=$false)][switch]$SilentWithFileOutput=$False,
	# Whether to export to CSV file rather than screen output
    [parameter(Mandatory=$false)][string]$UploadFolder = "\\miracl\scripts\Get-ARPInventory\gathereddata"
    )
#/B
    
#B
# Include library functions
If (test-path variable:$myinvocation.mycommand.path) {
  $ScriptDirectory = split-path -parent $MyInvocation.MyCommand.Path    
} Else {
  $ScriptDirectory = $PWD  
}
. "$ScriptDirectory\Get-ARPInventoryFunctions.ps1"
#/B


$FilteredARPs2 = Get-ARPInstalledSoftware
$NonFilteredARPs = Get-ARPInstalledSoftware -IncludeChildUpdates -IncludeKBUpdates -IncludeHiddenItems 

#If displaying screen output, show two grid views
#B
if (-not $SilentWithFileOutput) {
  $NonFilteredArps | select-object DisplayName, DisplayVersion, InstallDate, Publisher, UninstallString, GUIDFromUninstallString, KBGUIDFromKeyName, KBIDFromKeyName, PSParentPath, PSChildname | out-gridview -Title "EVERYTHING in The Registry (including hidden, child updates and KB updates): $($nonfilteredarps.count) Items"
  $FilteredArps2 | select-object DisplayName, DisplayVersion, InstallDate, Publisher, UninstallString, GUIDFromUninstallString, PSParentPath | out-gridview -Title "Add Remove Programs View: $($Filteredarps2.count) Items"
}
#/B

#B
if ($SilentWithFileOutput) {
   $CompName = $env:computername
   $TempPath = $env:temp
   If (Test-Path "$tempPath\$CompName-ARPINV.csv") {Remove-Item "$tempPath\$CompName-ARPINV.csv" -Force}
   $filteredarps2 | % { Add-Member -InputObject $_ -MemberType NoteProperty -Name ComputerName -Value $env:computername ; $_ } | select-object ComputerName, DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString, PSParentPath |  ConvertTo-Csv | Select -Skip 2 | Out-File "$tempPath\$CompName-ARPINV.csv" -Force
  
  #Export-Csv "$tempPath\$CompName-ARPINV.csv" -NoTypeInformation -Force
  If ($UploadFolder -and (Test-Path $Uploadfolder)) {
    Copy-Item "$tempPath\$CompName-ARPINV.csv" "$Uploadfolder\$CompName-ARPINV.csv" -Force
  }
} 
#/B

#B
write-host "*****************************************************************************"
write-host ""
write-host "               Total raw Registry Keys: $($NonfilteredArps.count)"
write-host ""
Write-host "After applying filters, script Returns: $($filteredarps2.Count)"
write-host "  [Compare this last number to a manual count on your machine]" 
write-host ""
write-host "*****************************************************************************"
write-host ""
#/B