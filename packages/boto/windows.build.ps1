$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
$LIB_INSTALL_DIR="$env:PKG_PATH\lib\site-packages"  
new-item -force -itemtype directory -path $LIB_INSTALL_DIR > $null

new-item -force -ItemType Directory c:\tmpPackage > $null

$packages = @("futures", "jmespath", "botocore", "boto3", "s3transfer") 
ForEach ($package in $packages) {
  $whl = get-item "c:\pkg\src\$package\*.whl"
  $params = @( "install", "--no-deps", "--no-index", "--target=`"c:\tmpPackage`"", "$whl" )
  & pip.exe $params
  if ($LASTEXITCODE -ne 0)
  {
      Write-Error "Failed to install $package"
      exit -1
  }
}

Copy-Item -force -Recurse "c:\tmpPackage\*" "$LIB_INSTALL_DIR\"

$cfn_signal="$env:PKG_PATH\bin\cfn-signal"
New-Item -ItemType Directory -Force "$env:PKG_PATH\bin"
copy-item "c:\pkg\extra\cfn-signal" "$cfn_signal"




