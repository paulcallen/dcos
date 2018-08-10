$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

$packages = @("chardet", "urllib3", "requests") 
ForEach ($package in $packages) {
  $whl = get-item "c:\pkg\src\$package\*.whl"
  $params = @( "install", "--no-deps", "--no-index", "--prefix=c:\tmpPackage", "--install-option=`"--install-scripts=c:\tmpPackage\bin\scripts`"", "$whl" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

Copy-Item -force -Recurse "c:\tmpPackage\*" "$env:PKG_PATH\"