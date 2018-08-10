$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

# set up path to find python in the container
$env:PATH+=";"

$whl = get-item "c:\pkg\src\$env:PKG_NAME\*.whl"
$params = @( "install", "--no-deps", "--no-index", "--target=`"c:\tmpPackage`"", "$whl")
& "pip.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install package"
    exit -1
}

Copy-Item -force -Recurse "c:\tmpPackage\*" "$LIB_INSTALL_DIR\"