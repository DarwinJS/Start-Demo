#BI
$WindowTitle = "CSI_AutoSwitch Bitness"
$NoBanner = $True
#/B

#
#CBH   Challenges: Launching PowerShell
#
#CY     [*] Whatever calls the script engine determines the 
#CY'        execution bitness of your script
#CY     [*] Default Windows execution will usually be 64-bit
#CY'         (e.g. Explorer, Startup Scripts & Group Policy, CMD.exe)
#CY     [*] Bitness of your script affects registry redirection & 
#CY'         access to windows utilities.
#CY'     [*] Leads to messy / duplicated code, duplicated wow6432node in registry.
#CY'     [*] Bitness of Script should follow software that it is configuring.
#'CY     [*] Sometimes You do not have control - example:
#'CY         SCCM 2007 Agents 32-bit, 2012 = 64-bit
#'CY         XP = 32-bit, Win7 = 64-bit
#'CY         Start a script from emailed link or IM = 32-bit
#
#CBH  Scenarios:
#
#CY     [*] A script that configures 32-bit software should always 
#CY'        run as 32-bit, whether started via email, windows or SCCM 2012
#CY'     [*] A script run by your 32-bit management agent must run as 64-bit
#
#'       Let's See It In Action...