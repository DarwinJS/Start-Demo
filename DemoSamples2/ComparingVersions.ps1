#
# Problems with zeros under normal circumstances
"2.3.4.705" -gt "2.3.00500.0"
#Types can have special processing for comparison operators.
#[version] converts the string to an object of type "[version]"
[version]"2.3.4.705" -gt [version]"2.3.00500.0"
# Problems with zeros under normal circumstances
"2.3.4.705" -eq "2.03.0004.0000000705"
#Using types (leading zeros disregarded)
[version]"2.3.4.705" -eq [version]"2.03.0004.0000000705"
# Versions must have at least one "."
[version]"2"
# with at least one dot it works
[version]"2.3"
# Throughout this demo we converting the type right when we compare, but we could also create a new variable of the [version] type:
$Version = [version]"2.3"
# $Version is now an object of type [version]
$Version
#Let's find out what properties are available for this type
$Version | Get-Member
#Grab an individual property:
$Version.Minor
#We can still address individual properties when using type conversion:
([version]"1.8.3.2").Minor	
# can compare versions of different number of positions
[version]"2.3.4.705" -eq [version]"2.3"
#unspecified positions treated as -1 (careful)
[version]"2.3.4.705" -gt [version]"2.3"
# easy to do ranging
([version]"2.3.4.705" -gt [version]"2.3") -and ([version]"2.3.4.705" -lt [version]"2.4.1") 
#Comparing File Versions
#Get-Command can retrieve internal versions on EXEs (get-member shows the properties):
Get-command cmd.exe | get-member
#FileVersionInfo holds properties regarding version
(Get-command cmd.exe).FileVersionInfo
#The property ProductVersion holds our version number
(Get-command cmd.exe).FileVersionInfo.ProductVersion
#We can make it into a version object
[version](Get-command cmd.exe).FileVersionInfo.ProductVersion
#How to compare file version to a known version number in one line
[version](get-command cmd.exe).FileVersionInfo.ProductVersion -gt [version]"6.1.7600"
#Version Comparing to installed products
#WARNING: There is much more code required to get a reliable, complete list of 
#installed software - to be covered at another time
$arps =  Get-ChildItem hklm:\software\microsoft\windows\currentversion\uninstall | ForEach-Object {Get-ItemProperty $_.pspath}
#Version List all
$arps | select DisplayName,DisplayVersion, Publisher, InstallDate | Ft -autosize
#Select Just our desired object
$arps | where-object {$_.Displayname -eq "Microsoft .NET Framework 4.5"} | Select DisplayName,DisplayVersion, Publisher, InstallDate | Ft -autosize
#Retrieve Only Its Version:
($arps | where-object {$_.Displayname -eq "Microsoft .NET Framework 4.5"} | Select DisplayVersion)[0].DisplayVersion
#Set it to a variable
$DotNetVersion = ($arps | where-object {$_.Displayname -eq "Microsoft .NET Framework 4.5"} | Select DisplayVersion)[0].DisplayVersion
#Take a peek at converting to a version:
[version]$DotNetVersion
#Find out if our .NET version is upgradeable by a patch:
([version]$DotNetVersion -ge [version]"4.5") -and ([version]$DotNetVersion -lt [version]"4.5.50710")
