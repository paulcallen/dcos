$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1

Write-Host "Installing python to directory ${env:PKG_PATH}"

$tmpdir = "c:\python364.tmp"
write-host "installing to temporary directory: $tmpdir"
$parameters = @{
    'FilePath' = "c:\pkg\src\python\python-3.6.4-amd64.exe"

    'ArgumentList' = @("/quiet", "/passive", "InstallAllUsers=1", "PrependPath=1", "Include_test=0", "Include_pip=0", "Include_tcltk=0", "TargetDir=`"$tmpdir`"")
    'Wait' = $true
    'PassThru' = $true
}
$p = Start-Process @parameters
if ($p.ExitCode -ne 0) {
    Throw "Failed to install python-3.6.4"
}

# Copy the directory structure to the final destination
New-Item -ItemType Directory -Force "$env:PKG_PATH\bin\" > $null
New-Item -ItemType Directory -Force "$env:PKG_PATH\lib\" > $null
copy-item -force -recurse -path "$tmpdir\*" -destination "$env:PKG_PATH\bin\"
move-item "$env:PKG_PATH\bin\lib\site-packages" "$env:PKG_PATH\lib\"
remove-item -Recurse -force $tmpdir




