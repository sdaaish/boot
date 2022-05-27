# Personal profile for Windows Powershell Desktop Edition, a basic one.
$readline = @{
    EditMode = "Emacs"
    HistorySearchCursorMovesToEnd = $true
    ContinuationPrompt = ">>"
    BellStyle = "None"
}

Set-PSReadLineOption @readline

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
    Write-Host "${time} [PS:${PSEdition}] - ${nextCommand} - ${env:USERNAME}@${env:COMPUTERNAME} ${currentDirectory}`n>" -ForeGroundColor 10 -NoNewLine
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
