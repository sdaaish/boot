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
if (-not $isLinux) {
    Install-PackageProvider -Name NuGet -Force
}
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Repository PSGallery -Force
Install-Module BuildHelpers -Repository PSGallery -Force

## Create directories in $env:USERPROFILE
foreach($dir in $dirs){
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force
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
Register-PSRepository @LocalRepositorySplat
Install-Module -Name MyModule -Repository $RepoSource.Name -Force
Import-Module MyModule -Force

if (-not $isLinux){
    Install-Scoop
    & scoop install git
}

# Clone my github repositories
foreach($repo in $gitrepos.GetEnumerator()){
    $src = $repo.value[0]
    $branch = $repo.value[1]

    $path = Join-Path -Path $homedir -ChildPath "repos"
    $destpath = Join-Path -Path $path -ChildPath $repo.key
    git -C $path clone -b $branch $src $destpath
}

# Set the executionpolicy for the system and not just the process. Only for Windows
if (-not $isLinux) {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Verbose
}
