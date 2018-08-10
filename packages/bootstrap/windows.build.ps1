$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

$params = @("install", "--no-deps", "--install-option=`"--prefix=c:\tmpPackage`"", "--install-option=`"--install-scripts=c:\tmpPackage\bin\scripts`"", "--root=c:\", "c:\pkg\extra")
& "pip.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install package"
    exit -1
}

Copy-Item -force -Recurse "c:\tmpPackage\*" "$env:PKG_PATH\"
