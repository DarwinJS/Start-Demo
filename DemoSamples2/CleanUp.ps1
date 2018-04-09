
#One liner to wipe clean multiple registry and file system trees
@("HKCU\Software\ABC", "C:\Program Files\ABC") | Remove-Item $_ -Recurse -Force -ErrorAction "SilentlyContinue"

#Making it a little more friendly:
#B
$PathsToRemove = @("HKCU\Software\ABC", "C:\Program Files\ABC")
$PathsToRemove | Remove-Item $_ -Recurse -Force -ErrorAction "SilentlyContinue"
#/B

#Getting feedback when paths don't exist.
#B
$PathsToRemove | 
Foreach-Object {
  If (Test-Path $_) {
    Remove-Item $_ -Recurse -Force -ErrorAction "SilentlyContinue"
  } else {
    write-host "  $_ does not exist."
  }
}
#/B
