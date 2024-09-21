# Personal profile for Windows Powershell Desktop Edition, a basic one.

# Fix for older Windows versions
#requires -Version 3.0

if ($host.Name -eq 'ConsoleHost'){
    $readline = @{
        EditMode = "Emacs"
        HistorySearchCursorMovesToEnd = $true
        ContinuationPrompt = ">>"
        BellStyle = "None"
        PredictionSource = "HistoryAndPlugin"
        PredictionViewStyle = "InLineView"
    }
}

if ((Get-Module -Name Psreadline).Version -gt 2.1){
    Set-PSReadLineOption @readline
}

# See https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-7.2
function prompt {
    # The at sign creates an array in case only one history item exists.
    $history = @(Get-History)
    if($history.Count -gt 0)
    {
	      $lastItem = $history[$history.Count - 1]
	      $lastId = $lastItem.Id
    }

    $nextCommand = $lastId + 1
    $currentDirectory = Get-Location
    $time = Get-Date -Format "yyyy-MM-dd HH:mm"

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    $context = $(if (Test-Path variable:/PSDebugContext) { "[DBG]" }
                 elseif($principal.IsInRole($adminRole)) { "[ADMIN]" }
                 else { '' })

    $ipaddress = Get-NetIPAddress -AddressFamily IPv4| ? InterfaceAlias -notmatch "Loopback"
    $ipaddress = $ipaddress.ipaddress -join " "

    $promptLine = @(
        "${time} [PS:${PSEdition}] - ${nextCommand}"
        "- ${env:USERNAME}@${env:COMPUTERNAME}:[${ipaddress}]"
        "${currentDirectory}`n${context} >"
    )
    $promptline = $promptLine -join " "
    Write-Host $promptLine  -ForeGroundColor Green -BackGroundColor Black -NoNewLine
    return " "
}

function ls {
    Get-ChildItem $args -Attributes H,!H,A,!A,S,!S
}
function ll {
    [cmdletbinding()]
    Param (
        $Path
    )

    Get-ChildItem $Path -Attributes H,!H,A,!A,S,!S
}

function lla {
    [cmdletbinding()]
    Param (
        $Path
    )
    Get-ChildItem $Path -Attributes H,!H,A,!A,S,!S,C,!C,E,!E
}

function lls {
    [cmdletbinding()]
    Param (
        $Path
    )
    Get-ChildItem $Path -Attributes H,!H,A,!A,S,!S|Sort-Object Length
}

function llt {
    [cmdletbinding()]
    Param (
        $Path
    )
    Get-ChildItem $Path -Attributes H,!H,A,!A,S,!S| Sort-Object lastwritetime
}

# Alias for help-command
function gh([string]$help) {
    $ErrorActionPreference = "Ignore"
    Get-Help -Name $help -Online
}

Function src {
    . $Profile
}

Function Test-Administrator {
    [cmdletbinding()]
    param()

    # Check for admin rights
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

# PSReadLine usually needs an update
Function Update-PSReadLine {
    if (Test-Administrator){
        Save-Module -Name PSReadLine -Path "C:\Program Files\WindowsPowerShell\Modules" -Force
    }
    else {
        Start-Process powershell.exe -ArgumentList '-NoProfile Save-Module -Name PSReadLine -Path "C:\Program Files\WindowsPowerShell\Modules" -Force' -Verb RunAs
    }
}

# Setup colors and change size on older terminals
Function Set-PSConsole {

    # Set colors
    $host.ui.RawUI.ForegroundColor = "White"
    $host.ui.RawUI.BackgroundColor = "Black"

    $colors = @{
        ErrorBackgroundColor = "Black"
        WarningBackgroundColor = "Black"
        VerboseBackgroundColor = "Black"
        ErrorForegroundColor = "Red"
        WarningForegroundColor = "DarkYellow"
        VerboseForegroundColor = "Yellow"
    }
    $colors.GetEnumerator()| foreach-object {
        $host.Privatedata.$($_.key) = $_.value
    }

    # Setup the buffer
    $buffer = $host.ui.RawUI.BufferSize
    $buffer.width = 120
    $buffer.height = 9999
    $host.UI.RawUI.Set_BufferSize($buffer)

    # Setup Windowsize based on actual size
    $maxWS = $host.UI.RawUI.Get_MaxWindowSize()
    $ws = $host.ui.RawUI.WindowSize
    if($maxws.width -ge 85){
        $ws.width = 85
    }
    else {
        $ws.width = $maxws.width
    }
    if($maxws.height -ge 42){
        $ws.height = 42
    }
    else {
        $ws.height = $maxws.height
    }
    $host.ui.RawUI.Set_WindowSize($ws)
}
