
$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmppip > $null

$params = @("-m", "pip", "install", "--no-deps", "--no-index", "--prefix=c:\tmpPackage", "c:\pkg\src\pywin32\pywin32-223-cp36-cp36m-win_amd64.whl")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install pywin32"
    exit -1
}

$params = @("-m", "pip", "install", "--no-deps", "--no-index", "--prefix=c:\tmpPackage", "c:\pkg\src\pypiwin32\pypiwin32-223-py3-none-any.whl")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install pypiwin32"
    exit -1
}

# portalocker is a portable version of fctrl that works on windows and linux.
# on linux it is just fctrl and on windows it maps to win32 APIs.
$params = @("-m", "pip", "install", "--no-deps", "--no-index", "--prefix=c:\tmpPackage", "c:\pkg\src\portalocker\portalocker-1.2.1-py2.py3-none-any.whl")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install portalocker"
    exit -1
}

Move-Item "c:\tmpPackage\scripts" "c:\tmpPackage\bin"
Copy-Item -force -Recurse "c:\tmpPackage\*" "$env:PKG_PATH\"

# Copy service units used to install dependency properly at run-time
new-item -ItemType Directory -Force "$env:PKG_PATH\dcos.target.wants"
Copy-Item "c:\pkg\extra\dcos-portalocker.windows.service" "$env:PKG_PATH\dcos.target.wants\dcos-portalocker.service"
