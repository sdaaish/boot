#requires -modules BuildHelpers

Function Build-TestDocker {

    if ($isWindows){
        $GitPath = (Get-Command "git.exe").source
    }
    else {
        $GitPath = (Get-Command "git").source
    }

    $ProjectName =  Get-ProjectName -Path $PSScriptRoot -GitPath $GitPath
    $ProjectVariable =  Get-BuildVariables -Path $PSScriptRoot
    $branch = $ProjectVariable.BranchName
    $ProjectVersion = $ProjectVariable.BuildNumber
    $tag = "${ProjectName}:${branch}-${ProjectVersion}".ToLower()
    "$tag"
    $dockeroptions = @(
        "--tag" ,"$tag"
        "--file" , (Join-Path -Path $PSScriptRoot -ChildPath "Build/Dockerfile")
        "$PSScriptroot"
    )
    & docker build @dockeroptions $ProjectPath
}

Build-TestDocker
