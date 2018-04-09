<#
Available Prepends (if text at line beginning contains the characters
   #   = Displays as comment 
   ##  = NON-displaying comment (must edit file to see)
   #B  = BLOCK Begin - displays and executes a multi-line block up to next End of Block Prepend (#/B)
   #/B = End of block
   #BI = BLOCK-INVISIBLE - execute to next End of Block (#/B) with no screen output
   '   = Pauses for input at end of line (use for appearing bullets)
   CB = Text color Blue
   CG = Text color Green
   CR = Text color Red
   CY = Text color Yellow
   H  = Heading = Convert to all Upper case
#>

## Revision History (version 4.1)

## 4.1 - Author:   October 2013 Darwin Sanoy of CloudyWindows.io
##     - Added:    Supports comment blocks "<# comments #>"
##     - Added:    Change colors of comment lines


## Revision History (version 4.0)

## 4.0 - Author:   June 2013 Darwin Sanoy of CloudyWindows.io
##     - Added:    Blank lines in demo file ignored
##     - Added:    ## lines in demo file do not display (double commented)
##     - Added:    #' line in demo file pause comment output (for Powerpoint like bullets)
##     - Added:    $EnableLineNumbers must be set to $true to output lines numbers at all.
##     - Added:    Only output line number & prompt if a command - not on comments
##     - Added:    Strips comment and control characters from non-command lines
##     - Added:    Ctrl-C is recognized as "quit" (whew that was painful)
##     - Added:    Implemented Pretend Typing and DisablePretendTyping switch
##     - Added:    Implemented $LeftMargin
##     - Added:    newline before only the first comment in a comment block
##     - Added:    Right or Down arrow cancels autotyping
##     - Added:    #B  <codelines> #/B (displays entire block without typing and executes
##     - Added:    #BI <codelines> #/B (executes entire block invisibly)
## 3.3.3 Fixed:    Script no longer says "unrecognized key" when you hit shift or ctrl, etc.
##       Fixed:    Blank lines in script were showing as errors (now printed like comments)
## 3.3.2 Fixed:    Changed the "x" to match the "a" in the help text
## 3.3.1 Fixed:    Added a missing bracket in the script
## 3.3 - Added:    Added a "Clear Screen" option
##     - Added:    Added a "Rewind" function (which I'm not using much)
## 3.2 - Fixed:    Put back the trap { continue; }
## 3.1 - Fixed:    No Output when invoking Get-Member (and other cmdlets like it???)
## 3.0 - Fixed:    Commands which set a variable, like: $files = ls
##     - Fixed:    Default action doesn't continue
##     - Changed:  Use ReadKey instead of ReadLine
##     - Changed:  Modified the option prompts (sorry if you had them memorized)
##     - Changed:  Various time and duration strings have better formatting
##     - Enhance:  Colors are settable: prompt, command, comment
##     - Added:    NoPauseAfterExecute switch removes the extra pause
##                 If you set this, the next command will be displayed immediately
##     - Added:    Auto Execute mode (FullAuto switch) runs the rest of the script
##                 at an automatic speed set by the AutoSpeed parameter (or manually)
##     - Added:    Automatically append an empty line to the end of the demo script
##                 so you have a chance to "go back" after the last line of you demo
##################################################################################################
##
param(
  $file=".\demo.txt", 
  [int]$command=0, 
  [System.ConsoleColor]$promptColor="Yellow", 
  [System.ConsoleColor]$commandColor="White", 
  [System.ConsoleColor]$commentColor="DarkGreen", 
  [switch]$FullAuto,
  [switch]$EnableLineNumbers,
  [int]$AutoSpeed = 3,
  [int]$LeftMargin = 3,
  [switch]$NoPauseAfterExecute,
  [switch]$DisablePretendTyping,
  [switch]$NoBanner=$True,
  [switch]$NoHeading,
  [string]$WindowTitle,
  [switch]$DebugMessages
)
  
  
[console]::TreatControlCAsInput = $true

$LeftMarginChars = (" " * $LeftMargin)

$RawUI = $Host.UI.RawUI
$hostWidth = $RawUI.BufferSize.Width

$_Random = New-Object System.Random
$_starttime = [DateTime]::now
$_InterkeyPause = 100
$_LastLineWasComment = $False
$_OriginalColor = $RawUI.ForeGroundColor
$_i = 0
$WroteBanner=$False


# A function for reading in a character 
function Read-Char() {
  $_OldColor = $RawUI.ForeGroundColor
  $RawUI.ForeGroundColor = "Red"
  
  if ([console]::KeyAvailable) {
    $key = [system.console]::readkey($true)
    if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
      Return "q"
    } else {
      Return $key.key
    }
  }

  # loop until they press a character, so Shift or Ctrl, etc don't terminate us
  while(!$key){
    if ([console]::KeyAvailable) {
      $key = [system.console]::readkey($true)
      if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
        Return "q"
    } Else { Return $key.key}
  }
  }
  $RawUI.ForeGroundColor = $_OldColor
  $keyvalue = $key.key
  return $keyvalue
}

function Rewind($lines, $index, $steps = 1) {
   $started = $index;
   $index -= $steps;
   while(($index -ge 0) -and ($lines[$index].Trim(" `t").StartsWith("#"))){
      $index--
   }
   if( $index -lt 0 ) { $index = $started }
   return $index
}

$file = Resolve-Path $file
while(-not(Test-Path $file)) {
  $file = Read-Host "Please enter the path of your demo script (Crtl+C to cancel)"
  $file = Resolve-Path $file
}

Clear-Host

$_lines = Get-Content $file
# Append an extra (do nothing) line on the end so we can still go back after the last line.
#$_lines += "Write-Host 'The End'"
$_starttime = [DateTime]::now

If (-not $NoBanner) {
Write-Host -nonew -back black -fore $promptColor $(" " * $hostWidth)
Write-Host -nonew -back black -fore $promptColor @"
<Demo Started :: $(split-path $file -leaf)>$(' ' * ($hostWidth -(18 + $(split-path $file -leaf).Length)))
"@
Write-Host -nonew -back black -fore $promptColor "Press"
Write-Host -nonew -back black -fore Red " ? "
Write-Host -nonew -back black -fore $promptColor "for help.$(' ' * ($hostWidth -17))"
Write-Host -nonew -back black -fore $promptColor $(" " * $hostWidth)
}

# We use a FOR and an INDEX ($_i) instead of a FOREACH because
# it is possible to start at a different location and/or jump 
# around in the order.

for ($_i = $Command; $_i -lt $_lines.count; $_i++)
{  
	# Put the current command in the Window Title along with the demo duration
	if ($WindowTitle -and -not $NoHeading -and -not $WroteBanner) {
      Write-Host -Foreground $CommentColor
	  Write-Host -Foreground $CommentColor  "   ********************************"
	  Write-Host -Foreground $CommentColor  "     CloudyWindows.io"
      Write-Host -ForeGround "DarkRed"      "     $WindowTitle"
	  Write-Host -Foreground $CommentColor  "   ********************************"
     $WroteBanner = $True
	 }
	
	$Title = $_Lines[$_i]
	If ($WindowTitle) {$Title = $WindowTitle}
	$Dur = [DateTime]::Now - $_StartTime
    $RawUI.WindowTitle = "$(if($dur.Hours -gt 0){'{0}h '})$(if($dur.Minutes -gt 0){'{1}m '}){2}s   {3}" -f 
                        $dur.Hours, $dur.Minutes, $dur.Seconds, $Title

	# Echo out the commmand to the console with a prompt as though it were real
	if ($DebugMessages) {Write-host "$($_lines[$_i]) `[Debug`]"}
    if (($_lines[$_i].Trim(" ").Length -eq 0) -or  ($_lines[$_i].Trim(" ") -eq "#"))
    {
	  $_LastLineWasComment = $True
	  write-host
      continue
    } elseif ($_lines[$_i].StartsWith("##")) {
	  $_LastLineWasComment = $False
      continue
	} elseif ($_lines[$_i].Trim(" ").StartsWith("#B") ) { 
         $BlockLineHeading = $_lines[$_i] 
         $_i++
         while (-not ($_lines[$_i].Trim(" ").StartsWith("#/B"))) {
           $BlockToExecute += $_Lines[$_i] + "`n"
           $_i++
           }
         if (-not $BlockLineHeading.StartsWith("#BI") ) {
           Write-Host -nonew -fore $commandColor "$BlockToExecute"
           }
        $_LastLineWasComment = $False
    } elseif ($_lines[$_i].Trim(" ").StartsWith("<#") ) { 
         $BlockLineHeading = $_lines[$_i] 
         $_i++
         while (-not ($_lines[$_i].Trim(" ").Contains("#>"))) {
           Write-Host -nonew -fore $commentColor $_Lines[$_i]"`n"
           $_i++
           }
        $_LastLineWasComment = $True
        continue
	  } elseif ($_lines[$_i].StartsWith("#")) {
        $CurrentColor = $CommentColor
        if (!$_LastLineWasComment) {write-host `n}
        $_lines[$_i] -match "^(?<lead>\S*)(?<line>\s.*)?" | Out-null
        $Leader = $matches["lead"]
        $ScreenLine = $matches["line"] 
       
        If ($DebugMessages) {write-host "`$Leader: $Leader`n`$line: $ScreenLine"}
                   
  		  if ($Leader.contains("H")) {$ScreenLine = $matches["line"].ToUpper()}
		  if ($Leader.contains("CR")) {$CurrentColor = "DarkRed"}
		  if ($Leader.contains("CB")) {$CurrentColor = "Blue"}
     	  if ($Leader.contains("CG")) {$CurrentColor = $CommentColor}
		  if ($Leader.contains("CY")) {$CurrentColor = "Yellow"}

          if ($Leader.contains("CLR")) {
		    Clear-Host ; Write-Host
		  } Else {
		    Write-Host -Foreground $CurrentColor "$ScreenLine"
		  }

        if ($Leader.contains("'")) {
          $pause = $RawUI.ReadKey("IncludeKeyUp")
		  }
        if (-not ($Leader.contains("O")))  {
          #write-host `n
		    }
			
		  $ScreenLine = $Leader = $null
		  $_LastLineWasComment = $True
          continue
    } else {
        Write-Host -nonew -fore $promptColor $LeftMarginChars
        If ($EnableLineNumbers) {Write-Host -nonew -fore $promptColor "[$_i]"}
        If ($EnablePSPrompt) {Write-Host -nonew -fore $promptColor "PS> "}

        # Put the current command in the Window Title along with the demo duration
        $_Duration = [DateTime]::Now - $_StartTime
        $Host.UI.RawUI.WindowTitle = "[{0}m, {1}s]    {2}" -f [int]$_Duration.TotalMinutes, [int]$_Duration.Seconds, $($_Lines[$_i])
        #Write-Host -NoNewLine $("`n[$_i]PS> ")
        
        If (-not $DisablePreTendTyping) {
          #If we are pretend typing...
          $_KeepOnPretendTyping = $true
          $_SimulatedLine = $($_Lines[$_i]) + "  "
          for ($_j = 0; $_j -lt $_SimulatedLine.Length; $_j++)
          {
             Write-Host -NoNewLine -fore $commandColor $_SimulatedLine[$_j]
             if ($_KeepOnPretendTyping)
             {
                 if ([System.Console]::KeyAvailable)
                 { 

                     $_KeepOnPretendTyping = $False
                     #$_Interuppted = $True
                 }
                 else
                 {
                     Start-Sleep -milliseconds $(10 + $_Random.Next($_InterkeyPause))
                 }
             }
          } # For $_j     
         
        } else {
          #No pretend typing - just put the line on the screen
          Write-Host -nonew -fore $commandColor "$($_Lines[$_i])  "
        }
				if($_Lines[$_i] -match '`') {
				  Write-Host 
					$EnableLineNumbers = $false
					$EnablePSPrompt = $false
				  continue
				}
        $_LastLineWasComment = $False
	  }

	  if( $FullAuto ) { 
       Start-Sleep $autoSpeed; $ch = [char]13 
     } Else { 
       $_OldColor = $RawUI.ForeGroundColor
       $RawUI.ForeGroundColor = "Red"
  
     if ([console]::KeyAvailable) {
        $key = [system.console]::readkey($true)
        if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
          $ch = "q"
        } elseif (($key.key -eq "RightArrow") -or ($key.key -eq "DownArrow") -or ($key.key -eq "$([char]13)") -or ($key.key -eq "Enter")) {
          $Key = $Null
        } else {
          $ch = $key.key
        }
      }

      # loop until they press a character, so Shift or Ctrl, etc don't terminate us
      while(!$key){
			  #Write-Host -NoNewline "*"
        if ([console]::KeyAvailable) {
          $key = [system.console]::readkey($true)
          if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
            $ch = "q"
        } Else { $ch = $key.key}
      }
      }
      $RawUI.ForeGroundColor = $_OldColor
    }
    
    # If $Ch is null, skip key selection.
    If ($Ch) {
    
    switch($ch)
	{
		{($_ -eq "Oem2") -or ($_ -eq "?")} {

			Write-Host -Fore $promptColor @"

Running demo: $file
(n) Next       (p) Previous
(q) Quit       (s) Suspend 
(t) Timecheck  (v) View $(split-path $file -leaf)
(g) Go to line by number
(f) Find lines by string
(a) Auto Execute mode
(c) Clear Screen
"@
			$_i-- # back a line, we're gonna step forward when we loop
		}
		"n" { # Next (do nothing)
			Write-Host -Fore $promptColor "<Skipping Line>"
		}
		"p" { # Previous
			Write-Host -Fore $promptColor "<Back one Line>"
			while ($_lines[--$_i].Trim(" ").StartsWith("#")){}
			$_i-- # back a line, we're gonna step forward when we loop
		}
		"a" { # EXECUTE (Go Faster)
			$AutoSpeed = [int](Read-Host "Pause (seconds)")
			$FullAuto = $true;
			Write-Host -Fore $promptColor "<eXecute Remaining Lines>"
			$_i-- # Repeat this line, and then just blow through the rest
		}		
        "q" { # Quit
           [console]::TreatControlCAsInput = $false            
			Write-Host -Fore $promptColor "<Quiting demo>"
            $RawUI.ForeGroundColor = $_OriginalColor
			$_i = $_lines.count;
			exit;
		}
		"v" { # View Source
			$lines[0..($_i-1)] | Write-Host -Fore Yellow 
			$lines[$_i]        | Write-Host -Fore Green
			$lines[($_i+1)..$lines.Count] | Write-Host -Fore Yellow 
			$_i-- # back a line, we're gonna step forward when we loop
		}
		"t" { # Time Check
			 $dur = [DateTime]::Now - $_StartTime
             Write-Host -Fore $promptColor $(
             "{3} -- $(if($dur.Hours -gt 0){'{0}h '})$(if($dur.Minutes -gt 0){'{1}m '}){2}s" -f 
             $dur.Hours, $dur.Minutes, $dur.Seconds, ([DateTime]::Now.ToShortTimeString()))
			 $_i-- # back a line, we're gonna step forward when we loop
		}
		"s" { # Suspend (Enter Nested Prompt)
			Write-Host -Fore $promptColor "<Suspending demo - type 'Exit' to resume>"
			$Host.EnterNestedPrompt()
			$_i-- # back a line, we're gonna step forward when we loop
		}
		"g" { # GoTo Line Number
			$i = [int](Read-Host "line number")
			if($i -le $_lines.Count) {
				if($i -gt 0) {
               # extra line back because we're gonna step forward when we loop
               $_i = Rewind $_lines $_i (($_i-$i)+1)
				} else {
					$_i = -1 # Start negative, because we step forward when we loop
				}
			}
		}
		"f" { # Find by pattern
			$match = $_lines | Select-String (Read-Host "search string")
			if($match -eq $null) {
				Write-Host -Fore Red "Can't find a matching line"
			} else {
				$match | % { Write-Host -Fore $promptColor $("[{0,2}] {1}" -f ($_.LineNumber - 1), $_.Line) }
				if($match.Count -lt 1) {
					$_i = $match.lineNumber - 2  # back a line, we're gonna step forward when we loop
				} else {               
					$_i-- # back a line, we're gonna step forward when we loop
				}
			}
		}
      "c" { 
         Clear-Host
         $_i-- # back a line, we're gonna step forward when we loop
      }
      "RightArrow" { 
            
      }		 
      {($_ -eq "$([char]13)") -or ($_ -eq "Enter")} { # on enter
			$RawUI.ForeGroundColor = "Red"
			Write-Host
			trap [System.Exception] {Write-Error $_; continue;}
   		if ($BlockToExecute) {
        $Scriptline = $BlockToExecute
        $BlockToExecute = $Null
      } else {
				$Scriptline = $_lines[$_i]	
			}

      Invoke-Expression $(".{ " + $Scriptline + "} | out-default")
      # original Invoke-Expression ($_lines[$_i]) | out-default
            $BackupOneLine = $False
			if(-not $NoPauseAfterExecute -and -not $FullAuto) { 
				$null = $RawUI.ReadKey("NoEcho,IncludeKeyUp")  # Pause after output for no apparent reason... ;)
			}
		}
		default
		{
			Write-Host -Fore Green "`n$LeftMarginChars Key $_ not recognized.  Press ? for help, or ENTER to execute the command."
			$_i-- # back a line, we're gonna step forward when we loop
		}
	}
  }


}

$dur = [DateTime]::Now - $_StartTime
If (-not $NoBanner) {
  Write-Host -Fore $promptColor $(
    "<Demo Complete -- $(if($dur.Hours -gt 0){'{0}h '})$(if($dur.Minutes -gt 0){'{1}m '}){2}s>" -f 
    $dur.Hours, $dur.Minutes, $dur.Seconds, [DateTime]::Now.ToLongTimeString())
  Write-Host -Fore $promptColor $([DateTime]::now)
  }
Write-Host

