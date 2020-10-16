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

# Variables
$homedir = $env:USERPROFILE
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

# Set defaults
Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerShellGet -Repository PSGallery -Force
Install-Module BuildHelpers -Repository PSGallery -Force

## Create directories in $env:USERPROFILE
foreach($dir in $dirs){
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force
}

# Register my own repository
$LocalRepositorySplat = @{
    Name = "AzurePowershellModules"
    SourceLocation = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v2"
    ScriptSourceLocation = "https://pkgs.dev.azure.com/sdaaish/PSModules/_packaging/AzurePSModuleRepo/nuget/v2"
    InstallationPolicy = "Trusted"
    PackageManagementProvider = "NuGet"
}
Register-PSRepository @LocalRepositorySplat
Install-Module -Name MyModule -Repository AzurePowershellModules -Force
Import-Module MyModule -Force
Install-Scoop
& scoop install git

# Clone my github repositories
foreach($repo in $gitrepos.GetEnumerator()){
    $src = $repo.value[0]
    $branch = $repo.value[1]

    $path = Join-Path -Path $homedir -ChildPath "repos"
    $destpath = Join-Path -Path $path -ChildPath $repo.key
    git -C $path clone -b $branch $src $destpath
}
