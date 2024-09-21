<#
.SYNOPSIS
Install Chezmoi

.DESCRIPTION
Installs WinGet and dependencies if not already installed, and then Chezmoi WinGet.
#>

function Install-Winget {
    [cmdletbinding()]
    param()

    process {
        $progressPreference = 'SilentlyContinue'
        Write-Information "Downloading WinGet and its dependencies..."

        $downloads = Join-Path (Resolve-Path ${env:USERPROFILE}) Downloads
        pushd $downloads

        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx

        Write-Information "Adding packages"
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        Write-Information "Cleaning up"
        Remove-Item Microsoft.VCLibs.x64.14.00.Desktop.appx -Force
        Remove-Item Microsoft.UI.Xaml.2.8.x64.appx -Force
        Remove-Item Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -Force
    }
}

Function refreshenv {
    $paths = @(
				([System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ([io.path]::PathSeparator))
				([System.Environment]::GetEnvironmentVariable("Path", "User") -split ([io.path]::PathSeparator))
    )
    $env:path = ($paths | Select-Object -Unique) -join ([io.path]::PathSeparator)
}

# Install WinGet if not already installed
try { Get-Command winget.exe -ErrorAction Stop }
catch { Install-Winget }

# Update the path
refreshenv

# Install chezmoi
try { Get-Command chezmoi.exe -ErrorAction Stop}
catch { winget install --id twpayne.chezmoi --source winget --accept-source-agreements }

refreshenv

Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
