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
Param (
)

# Enable logging
Start-Transcript

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
    ".local/WindowsPowerShell"
    ".local/PowerShell"
    ".config/git"
)

## Create directories in $env:USERPROFILE
foreach($dir in $dirs){
    Write-Host "Creating directory $dir"
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force|Out-Null
}

# My own repository
$RepoSource = @{
    Name = "AzurePowershellModules"
    Location = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v2"
    Provider = "NuGet"
}

# Set defaults
Write-Verbose "Installing NuGet"
if (-not $isLinux) {
    try {
        Get-PackageProvider -Name NuGet -ErrorAction Stop| Out-Null
    }
    catch {
        Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -ForceBootStrap
    }
}

# Save modules to local storage
if ($isLinux){
    $ModulePath = Resolve-Path "~/.local/share/powershell/Modules"
}
else {
    # Check wich version of Powershell
    switch ($PSVersionTable.PSEdition){
        "Core" {$version = "PowerShell/Modules"}
        "Desktop" { $version = "WindowsPowerShell/Modules"}
    }
    $ModulePath = Join-Path -Path (Resolve-Path "~/.local") -ChildPath $version
}

# Add local Module-drirectory to ModulePath
$env:PSModulePath = $env:PSModulePath + ";${ModulePath};"

Write-Verbose "Installing modules"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Save-Module -Name PowerShellGet -Path $ModulePath -Repository PSGallery -MinimumVersion 2.2.5 -Force
Save-Module -Name BuildHelpers -Path $ModulePath -Repository PSGallery -Force

# The settings for my local Powershell Modules Repository
$LocalRepositorySplat = @{
    Name = $RepoSource.Name
    SourceLocation = $RepoSource.Location
    ScriptSourceLocation = $RepoSource.Location
    InstallationPolicy = "Trusted"
    PackageManagementProvider = $RepoSource.Provider
}

# Register the repository
Write-Verbose "Registering my module."
Register-PSRepository @LocalRepositorySplat
Save-Module -Name MyModule -Path $ModulePath -Repository $RepoSource.Name -Force
Import-Module MyModule -Force

if (-not $isLinux){
    Write-Verbose "Installing scoop."
    Install-Scoop
    try {
        & scoop install git
    }
    catch {
        Write-Error "git already installed."
    }
}

# Get dotgit repository
Install-DotGit -Force

# Set the executionpolicy for the system and not just the process. Only for Windows
if (-not $isLinux) {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Verbose -ErrorAction Ignore
}

Stop-Transcript
