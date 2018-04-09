<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

$lines = get-content ".\msi.log"
Foreach ($line in $lines) {

Start-Sleep -Seconds 1

Add-Content ".\msi2.log" $line

}