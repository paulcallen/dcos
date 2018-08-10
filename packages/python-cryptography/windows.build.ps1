$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$env:LIB_INSTALL_DIR="$tmppackage\lib\site-packages"
new-item -force -itemtype directory -path $env:LIB_INSTALL_DIR > $null

$env:PKG_CONFIG_PATH="c:\opt\mesosphere\lib\pkgconfig"

new-item -force -ItemType Directory "c:\tmppackage" > $null

$env:PYTHONPATH="c:\tmppackage\lib\site-packages\;$env:PYTHONPATH"

$packages = @("asn1crypto") 
ForEach ($package in $packages) {
  $whl = get-item "c:\pkg\src\$package\*.whl"
  $params = @( "install", "--no-deps", "--no-index", "--prefix=c:\tmppackage", "$whl" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

$packages = @("cffi")
ForEach ($package in $packages) {
  $params = @( "install", "--no-deps", "--install-option=`"--prefix=c:\tmppackage`"", "--root=c:\", "c:\pkg\src\$package" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

$packages = @("cryptography") 
ForEach ($package in $packages) {
  $whl = get-item "c:\pkg\src\$package\*.whl"
  $params = @( "install", "--no-deps", "--no-index", "--prefix=c:\tmppackage", "$whl" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

Copy-Item -force -Recurse "c:\tmppackage\*" "$env:PKG_PATH\"
