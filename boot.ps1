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
$homedir = $env:USERPROFILE
$dirs = @(
    "tmp"
    "repos"
    "bin"
)
foreach($dir in $dirs){
    New-Item -Path (Join-Path -Path $homedir -ChildPath $dir) -ItemType Directory -Force
}
$gitrepos = @{
    "powershell-stuff" = "https://github.com/sdaaish/powershell-stuff.git", "develop"
}
foreach($repo in $gitrepos.GetEnumerator()){
    $src = $repo.value[0]
    $branch = $repo.value[1]
    $destpath = Join-Path -Path $homedir -ChildPath "repos" -AdditionalChildPath $repo.key
    git clone -b $branch $src $destpath
}
