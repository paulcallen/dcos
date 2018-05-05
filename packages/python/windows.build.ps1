
$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmppip > $null

$params = @("-m", "ensurepip", "--root", "c:\tmppip")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install pip and setuptools"
    exit -1
}

#temporarily add pip modules to the path for cython install. 
#next package will find it in the proper place.
$env:PYTHONPATH+=";c:\tmppip\opt\mesosphere\bin\lib\site-packages"

new-item -force -ItemType Directory c:\tmpPackage > $null
Move-Item "c:\tmppip\opt\mesosphere\bin\scripts" "c:\tmppip\opt\mesosphere\bin\bin"
copy-item "c:\tmppip\opt\mesosphere\bin\bin\pip3.exe" "c:\tmppip\opt\mesosphere\bin\bin\pip.exe"
copy-item "c:\tmppip\opt\mesosphere\bin\bin\easy_install-3.6.exe" "c:\tmppip\opt\mesosphere\bin\bin\easy_install.exe"
Copy-Item -force -Recurse "c:\tmppip\opt\mesosphere\bin\*" "$env:PKG_PATH\"

$params = @("-m", "pip", "install", "--no-deps", "--install-option=`"--prefix=c:\tmpPackage`"", "--root=c:\", "c:\pkg\src\cython")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install cython"
    exit -1
}

$params = @("-m", "pip", "install", "--no-deps", "--install-option=`"--prefix=c:\tmpPackage`"", "--root=c:\", "c:\pkg\src\pywin32")
& "python.exe" $params
if ($LASTEXITCODE -ne 0)
{
    Write-Error "Failed to install pywin32-ctypes"
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
