powershell.exe -NoProfile -ExecutionPolicy ByPass -Command {Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force -Verbose}
powershell.exe -NoProfile -ExecutionPolicy ByPass -File ./boot.ps1
