$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

# Install wheels.
$packages = @("adal", "analytics-python", "azure-nspkg", "azure-common", "azure-mgmt-nspkg", 
              "azure-mgmt-network", "azure-storage", "beautifulsoup4", "docutils", "keyring", 
              "msrest", "msrestazure", "py", "requests-oauthlib", "schema", "webob") 
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

$packages = @("aiohttp", "checksumdir", "coloredlogs", "docker-py", "humanfriendly", "multidict", 
              "oauthlib", "waitress", "websocket-client" )
ForEach ($package in $packages) {
  $params = @( "install", "--no-deps", "--install-option=`"--prefix=c:\tmpPackage`"", "--install-option=`"--install-scripts=c:\tmpPackage\bin\scripts`"", "--root=c:\", "c:\pkg\src\$package" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

Copy-Item -force -Recurse "c:\tmpPackage\*" "$env:PKG_PATH\"