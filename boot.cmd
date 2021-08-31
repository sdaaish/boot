powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy ByPass -Command {Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force -Verbose}
powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy ByPass -WindowStyle Normal -File ./boot.ps1 -Verbose
