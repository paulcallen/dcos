$ErrorActionPreference = "stop"

# Do install of pre-made package
$FILENAME_PATH = "c:\pkg\src\libarchive\libarchive-2.4.12-1-setup.exe"
$INSTALL_ARGS = @("/VERYSILENT","/SUPPRESSMSGBOXES","/SP-", "/DIR=`"$env:PKG_PATH\`"")

$parameters = @{
    'FilePath' = $FILENAME_PATH
    'ArgumentList' = $INSTALL_ARGS
    'Wait' = $true
    'PassThru' = $true
}

Write-Output "Installing $FILENAME_PATH"

$p = Start-Process @parameters
if($p.ExitCode -ne 0) {
    Throw "Failed to install $FILENAME_PATH"
}
