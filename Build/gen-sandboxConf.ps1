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

$bootFolder = Split-Path -Path $PSScriptroot -Parent
$wsbFile = Join-Path -Path $PSScriptRoot -ChildPath "boot-sandbox.wsb"
$cmdFile = Join-Path -Path $PSScriptRoot -ChildPath "boot-sandbox.cmd"

# Generate the cmd-file that are used _inside_ the Sandbox
$cmdContent = @"
@echo off

:: Local script to test installation in Windows Sandbox
cd C:\Users\WDAGUtilityAccount\Desktop\boot
cmd /c boot.cmd

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
   <Command>cmd.exe /c C:\Users\WDAGUtilityAccount\Desktop\boot\Build\boot-sandbox.cmd</Command>
</LogonCommand>
</Configuration>

"@

Set-Content -Path $wsbFile -Value $wsbContent -Force -Encoding utf8 -NoNewLine
Set-Content -Path $cmdFile -Value $cmdContent -Force -Encoding utf8 -NoNewLine

Write-Output "Generated Windows sandbox file in ${wsbFile}."
Write-Output "Start sandbox with '& .\'${wsbFile}."
