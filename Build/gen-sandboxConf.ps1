<#
.SYNOPSIS
Generates configuration for Windows Sandbox.

.DESCRIPTION
Run this to create files to be able to test the installation process in Windows Sandbox.

.PARAMETER Foobar
Descriptions of parameter Foobar

.EXAMPLE
./gen-sandboxConf.ps1

.NOTES
Only for testing with Windows Sandbox locally.
#>

$sandboxName = "boot-sandbox"
$bootFolder = Split-Path -Path $PSScriptroot -Parent
$wsbFile = Join-Path -Path $PSScriptRoot -ChildPath "${sandboxName}.wsb"

# Guest folders and startup file to execute
$guestHome = "C:\Users\WDAGUtilityAccount"
$guestPoshFile = Join-Path -Path $guestHome -ChildPath "Desktop\boot\boot.ps1"

# Autorun this _inside_ the Sandbox
$cmdContent = @"
Powershell Start-Process Powershell -WorkingDirectory $guestHome -WindowStyle Maximized -Argumentlist '-NoProfile -NoLogo -NoExit -ExecutionPolicy Bypass -File $guestPoshFile'
"@

# Generate the wsb-file to use to start the sandbox from Windows (outside).
$wsbContent = @"
<Configuration>
 <VGpu>Default</VGpu>
 <Networking>Default</Networking>
 <MappedFolders>
  <MappedFolder>
   <HostFolder>${bootFolder}</HostFolder>
   <ReadOnly>true</ReadOnly>
  </MappedFolder>
 </MappedFolders>
 <LogonCommand>
  <Command>${cmdContent}</Command>
 </LogonCommand>
</Configuration>

"@

Set-Content -Path $wsbFile -Value $wsbContent -Force -Encoding utf8 -NoNewLine

Write-Output "Generated Windows sandbox file in ${wsbFile}."
Write-Output "Start sandbox with '& .\'${wsbFile}."
