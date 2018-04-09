
#We can use stop-process to kill processes, however it takes a process object or stream of them
# So we must list the processes we want with get-process to turn them into process objects and
# pipe that to stop-process.

#Start some processes
1..3 | %{Start-Process notepad}
1..2 | %{Start-Process calc}

#List a Process
Get-Process "calc"

#List more than one at a time (alway watch for "multiple items" ability of PowerShell - 
# it saves a ton of time!)
Get-Process @("calc","notepad")

# To stop any instances, hand them to stop-process
Get-Process @("calc","notepad") | Stop-Process -force

#What happens if their aren't any instances?
Get-Process @("calc","notepad") | Stop-Process -force

#Let's make errors silent because it most likely means there aren't any instances:

#setup the list in a variable
$global:proclist = @("calc","notepad")
Get-Process $proclist -ErrorAction SilentlyContinue | Stop-Process -force

#Are they there anymore?
Get-Process @("calc","notepad") | Stop-Process -force

#Start some processes again
#B
1..3 | %{Start-Process notepad}
1..2 | %{Start-Process calc}
#/B

#' But what if you just want to detect any instances and maybe prompt the user?

#B
Start-Process notepad
Start-Process calc
#/B
#Detect the count
@(get-process $proclist -erroraction silentlycontinue).count

#Type Accelerate to Boolean
$global:AtLeastOneRunning = [bool]@(get-process $proclist -erroraction silentlycontinue).count
$AtLeastOneRunning

if ($AtLeastOneRunning) {Write-Host "Please exit your applications or I will have to terminate them."}

Get-Process $proclist -ErrorAction SilentlyContinue | Stop-Process -force

if ([bool]@(get-process $proclist -erroraction silentlycontinue).count) {Write-Host "Calc and Notepad are not running, continuing install..."}


