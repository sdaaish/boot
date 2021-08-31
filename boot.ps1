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
if (-not $isLinux){
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
    ".local"
    ".config/git"
)

# Add local repositories
$gitrepos = @{
    "powershell-stuff" = "https://github.com/sdaaish/powershell-stuff.git", "develop"
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

Write-Verbose "Installing modules"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -MinimumVersion 2.2.5 -AllowClobber -Force
Install-Module -Name BuildHelpers -Repository PSGallery -Scope CurrentUser -Force

## Create directories in $env:USERPROFILE
foreach($dir in $dirs){
    Write-Host "Creating directory $dir"
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force|Out-Null
}

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
Install-Module -Name MyModule -Repository $RepoSource.Name -Scope CurrentUser -Force
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

# Clone my github repositories
Write-Verbose "Downloading repositories from github. "
foreach($repo in $gitrepos.GetEnumerator()){
    $src = $repo.value[0]
    $branch = $repo.value[1]

    $path = Join-Path -Path $homedir -ChildPath "repos"
    $destpath = Join-Path -Path $path -ChildPath $repo.key

    try {
        Write-Host "Cloning ${src} to ${destpath}"
        git -C $path clone -b $branch $src $destpath
    }
    catch {
        Write-Error "$destpath not empty!"
    }
}

# Set the executionpolicy for the system and not just the process. Only for Windows
if (-not $isLinux) {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Verbose -ErrorAction Ignore
}

Stop-Transcript
