$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1

$SRC_DIR = "c:\gopath\src\github.com\dcos\dcos-diagnostics\"
new-item -itemtype directory -force "c:\gopath\src\github.com\dcos"
copy-item -recurse -Force "c:\pkg\src\dcos-diagnostics" -destination "c:\gopath\src\github.com\dcos\"
Push-Location $SRC_DIR
& go get
if ($LASTEXITCODE -ne 0)
{
    throw "Failed to 'go get'"
}
& .\scripts\make.ps1 "build"
if ($LASTEXITCODE -ne 0)
{
    throw "Failed tobuild dcos-metrics"
}
# Copy the build from the bin to the correct place
new-item -itemtype directory -force "$env:PKG_PATH\bin"
copy-item -Recurse -force c:\gopath\bin\* "$env:PKG_PATH\bin"
