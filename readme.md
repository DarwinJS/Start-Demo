
This code has not been updated since October 2013 - so it probably needs some work.

Seems somewhat compatible with Powershell 6.

Open to pull requests!

This code supports these new prepends:

   ```
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
   ```

Change / Feature Log:

```
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
```   