#requires -modules BuildHelpers

Function Build-TestDocker {

    if ($isWindows){
        $GitPath = Get-Command "git.exe"
    }
    else {
        $GitPath = Get-Command "git"
    }

    $Project = Get-BuildEnvironment -Path (Split-Path -Path $PSScriptRoot -Parent) -GitPath $GitPath
    $ProjectManifest = $Project.PSModuleManifest
    $ProjectName =  $Project.ProjectName
    $ProjectVersion =  Get-Metadata -Path $ProjectManifest
    $ProjectPath = $Project.ProjectPath
    $branch = $Project.BranchName
    $tag = "${ProjectName}-${branch}:${ProjectVersion}".ToLower()

    $dockeroptions = @(
        "--tag" ,"$tag"
        "--file" , (Join-Path -Path $PSScriptRoot -ChildPath "Dockerfile")
    )
    & docker build @dockeroptions $ProjectPath
}

Build-TestDocker
