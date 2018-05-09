$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
7z x "c:\pkg\src\windows-powershell-core\PowerShell-6.0.2-win-x64.zip" "-o$env:PKG_PATH\bin"