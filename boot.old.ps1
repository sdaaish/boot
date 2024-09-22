<#
.SYNOPSIS
Simple installation script for new computers

.DESCRIPTION
To be done

.PARAMETER Foobar
none

.EXAMPLE
tbd

.NOTES
Some notes
#>
[cmdletbinding()]
Param ()

# Enable logging
Start-Transcript

# To check if admin
Function Test-Administrator {
    param()

    # Check for admin rights
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

if (-not (Test-Administrator)) {
    throw "Need to run this Administrator"
}

# Add certificates if they exist. Useful for testing the build.
$Path = Join-Path $PSScriptRoot Build
Get-ChildItem -Path $Path -File -Filter *.cer | Foreach-Object {
    Write-verbose "Installing certificate: ${$_.FullName}"
    certutil -addstore Root $_.FullName
}

# Variables
if (-not $isLinux){     # Windows
    $homedir = $env:USERPROFILE
}
else {
    $homedir = $ENV:HOME
}

# Directories to create
$dirs = @(
    "tmp"
    "repos"
    "bin"
    "work"
    "code"
    ".local"
    ".local/WindowsPowerShell/Modules"
    ".local/PowerShell/Modules"
    ".config/git"
)

## Create directories in $env:USERPROFILE
foreach($dir in $dirs){
    Write-Host "Creating directory $dir"
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force|Out-Null
}

# Set defaults
Write-Verbose "Installing NuGet"
if (-not $isLinux) {
    try {
        Get-PackageProvider -Name NuGet -ForceBootStrap -ErrorAction Stop| Out-Null
    }
    catch {
        Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -ForceBootStrap
    }
    finally {
        Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet
        Set-PackageSource -Name nuget.org -Trusted
    }
}

# Save modules to local storage
if ($isLinux){
    $ModulePath = Resolve-Path "~/.local/share/powershell/Modules"
} else {
    # Check wich version of Powershell
    switch ($PSVersionTable.PSEdition){
        "Core" {$version = "PowerShell/Modules"}
        "Desktop" { $version = "WindowsPowerShell/Modules"}
    }
    $ModulePath = Join-Path -Path (Resolve-Path "~/.local") -ChildPath $version
}

# Add local Module-directory to ModulePath
$env:PSModulePath = $env:PSModulePath + ";${ModulePath};"

Write-Verbose "Installing modules"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Save-Module -Name PowerShellGet -Path $ModulePath -Repository PSGallery -MinimumVersion 2.2.5 -Force
Save-Module -Name BuildHelpers -Path $ModulePath -Repository PSGallery -Force
Save-Module -Name Posh-Git -Path $ModulePath -Repository PSGallery -Force
Save-Module -Name Terminal-Icons -Path $ModulePath -Repository PSGallery -Force

switch ($version) {
    "Desktop" {Save-Module PSReadLine -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Force}
    "Core" {Save-Module PSReadLine -Path 'C:\Program Files\PowerShell\Modules\' -Force}
}

# The settings for my local Powershell Modules Repository
$LocalRepositorySplat = @{
    Name = "AzurePowershellModules"
    SourceLocation = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v2"
    ScriptSourceLocation = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v2"
    InstallationPolicy = "Trusted"
    PackageManagementProvider = $RepoSource.Provider
    Provider = "NuGet"
}

# Register the repository for PowerShellGet, the old method
Write-Verbose "Registering my module."
Register-PSRepository @LocalRepositorySplat -ErrorAction Ignore
Save-Module -Name MyModule -Path $ModulePath -Repository $RepoSource.Name -Force
Import-Module MyModule -Force

# Register the repository for Microsoft.PowerShell.PSResourceGet
# This supports version 3
$RepoSource = @{
    Name = "AzurePowershellModules"
    Uri = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v3/index.json"
    Trusted = $true
    Priority = 40
}

Register-PSResourceRepository @RepoSource

if (-not $isLinux){
    Write-Verbose "Installing winget."
    try {
        Install-Winget -ErrorAction Stop
    }
    catch {
        throw "Failed to install winget"
    }
}

# Install software with Winget
$options = @("--source", "winget", "--accept-package-agreements", "--accept-source-agreements")
$silent = @($options, "--silent")
& winget install Git.Git $options
& winget install 7zip.7zip $silent
& winget install Microsoft.PowerShell $silent
& winget install Starship.Starship $silent
& winget install twpayne.chezmoi $silent

# Windows Terminal
& winget install  Microsoft.WindowsTerminal $options  --scope user

# Create path to make the rest work
$path =  $(
    'C:\Program Files\PowerShell\7'
    'C:\Program Files\Git\bin'
    'C:\Program Files\7-Zip'
    'C:\Program Files\starship\bin\'
)

$oldpath =$env:path -split ";"
$env:path = (($oldpath + $path) -join ";") -replace ";{2,}",";"

$fileName = ".config{0}powershell{0}profile.ps1" -f [System.IO.Path]::DirectorySeparatorChar
$text = @"
`$StartTime = [System.Diagnostics.Stopwatch]::new()
. $(Join-Path (Resolve-Path ~) $fileName))
"@

# Set the executionpolicy for the system and not just the process. Only for Windows
if (-not $isLinux) {
    $DesktopProfile = powershell -Command {$profile} -NoLogo -NoProfile -ExecutionProfile Bypass
    $CoreProfile = pwsh -Command {$profile} -NoLogo -NoProfile -ExecutionProfile Bypass
    New-Item -Path (Split-Path $DesktopProfile -Parent) -ItemType Directory -Force|Out-Null
    New-Item -Path (Split-Path $CoreProfile -Parent) -ItemType Directory -Force|Out-Null
    Add-Content -Path $DesktopProfile -Value $text
    Add-Content -Path $CoreProfile -Value $text

    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Verbose -ErrorAction Ignore
}

Stop-Transcript
