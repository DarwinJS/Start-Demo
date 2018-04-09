#
# Sometimes you need to update a file in every user profile:
#'  [*] Clean up all temp folders
#'  [*] Update INI file
#'  [*] Add a file or folder.
#'  [*] Delete a file or folder.

#List folders under profile folder
Get-ChildItem "C:\users" | Where-Object {$_.PSIsContainer}

#Get only the name:
Get-ChildItem "C:\users" | Where-Object {$_.PSIsContainer} | select name

#Test passing name into foreach object for processing:
Get-ChildItem "C:\users" | Where-Object {$_.PSIsContainer} | select name | ForEach-Object { Write-Host $_.name }

#Delete instead of display
Get-ChildItem "C:\users" | Where-Object {$_.PSIsContainer} | select name | ForEach-Object {Remove-Item "C:\users\$_.name\appdata\local\temp\test.txt" -force -recurse }

#Must resolve object reference to a string
Get-ChildItem "C:\users" | Where-Object {$_.PSIsContainer} | select name | ForEach-Object {Remove-Item "C:\users\$($_.name)\appdata\local\temp\test.txt" -force -recurse}

#Can softcode the Userprofile folder this way (must use "PUBLIC" to work under SYSTEM account):
Get-ChildItem "$(split-path $env:public -parent)" | Where-object {$_.PSIsContainer} | select name | ForEach-Object {Remove-Item "$(split-path $env:public -parent)\$($_.name)\appdata\local\temp\test.txt" -force -recurse}

#Make it best effort by ignoring errors (existence, permissions, etc)
Get-ChildItem "$(split-path $env:public -parent)" | Where-object {$_.PSIsContainer} | select name | ForEach-Object {Remove-Item "$(split-path $env:public -parent)\$($_.name)\appdata\local\temp\test.txt" -force -recurse -erroraction SilentlyContinue}

#Another example for cleaning up App-V User settings for a given App-V package
Get-ChildItem "$(split-path $env:public -parent)" | Where-object {$_.PSIsContainer} | select name | ForEach-Object {Remove-Item "$(split-path $env:public -parent)\$($_.name)\appdata\roaming\softgrid client\YCC8FJAB.6LI-D5105B20-915F-4898" -force -recurse -erroraction SilentlyContinue}

#Cleaning a folder or lnk off all user start menus - both the root of "start menu" and "start menu\programs"
get-childitem "$(split-path $env:public -parent)" | Where-object {$_.PSIsContainer} | select name | %{Remove-Item "$(split-path $env:public -parent)\$($_.name)\appdata\roaming\microsoft\windows\start menu\ABC Software" -force -recurse -erroraction SilentlyContinue}
get-childitem "$(split-path $env:public -parent)" | Where-object {$_.PSIsContainer} | select name | %{Remove-Item "$(split-path $env:public -parent)\$($_.name)\appdata\roaming\microsoft\windows\start menu\programs\ABC Software" -force -recurse -erroraction SilentlyContinue}
