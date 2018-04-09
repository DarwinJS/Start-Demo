#BI
$WindowTitle = "Easy Launcher for PowerShell"
$NoBanner = $True
#/B

#
#CBH'   Challenges: Launching PowerShell
#
#CY'     [*] Double-clicking Opens in Notepad (Default)
#CY'     [*] May need to elevate (if users are admin)
#CY     [*] User Instructions Can Be Challenging 
#'CY         (esp. if Elevation steps are required)
#CY'     [*] UNC execution requires long paths to entered.
#CY     [*] Best practice execution options add complexity.
#CY'         (e.g. -noprofile -executionpolicy bypass, etc) 
#'CY     [*] User's can terminate PowerShell script if console window is left open.
#'CY     [*] If PowerShell Script needs arguments, it is even more challenging
#CY     [*] May need to support multiple "runs" of the PS1 with 
#'CY         different arguments.
#CLR
#
#CBH'  Scenarios:
#
#CY'     [*] Users Launching From Emailed / IM'ed Links (self-help).
#CY'     [*] Testers Launching for early access.
#CY     [*] Technician Launching for resolving support problems.
#CY'         (do not need to remember args, multiple CMDs for multiple args runs)
#CY     [*] Launching from Management Systems 
#'CY         (so packager specifies exact command line).
#
#CBH'  Demo Time...
#CLR

#CLR
#CBH'  Wrap Up:

#'CY     [*] Makes it super easy to distribute links to scripts (end users, techs)

#'CY     [*] Effortless customization via PS1 name matching.

#'CY     [*] Request elevation.

#'CY     [*] Works for network UNCs and Drive letters.

#'CY     [*] Hide extra windows from users so they don't terminate scripts. 

#CY     [*] Provides easy hand off from scripter to job distribution.
#CY'          techncian. (including args)

#'CY     [*] Multiple argument scenarios without need to remember args each time.

#'CY     [*] Descriptive names make arg scenarios easy to determine / remember.
