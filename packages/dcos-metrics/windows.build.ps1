$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1

$SRC_DIR = "c:\gopath\src\github.com\dcos\dcos-metrics\"
new-item -itemtype directory "c:\gopath\src\github.com\dcos" > $null
copy-item -recurse  "c:\pkg\src\dcos-metrics" -destination "c:\gopath\src\github.com\dcos\"
Push-Location $SRC_DIR
new-item -itemtype directory "c:\gopath\src\github.com\dcos\dcos-metrics\build" > $null
& .\scripts\build.ps1 "collector" "statsd-emitter" "plugins"
if ($LASTEXITCODE -ne 0)
{
    throw "Failed to build dcos-metrics"
}
new-item -itemtype directory "$env:PKG_PATH/bin" > $null
Copy-Item -Path "$SRC_DIR\build\collector\dcos-metrics-collector-*" -Destination "$env:PKG_PATH/bin/dcos-metrics.exe"
Copy-Item -Path "$SRC_DIR\build\statsd-emitter\dcos-metrics-statsd-emitter-*" -Destination "$env:PKG_PATH/bin/statsd-emitter.exe"
Pop-Location

# Create the service file for all roles 
$agent_service="$env:PKG_PATH\dcos.target.wants_slave\dcos-metrics-agent.service"
$agent_service_dir = Split-Path $agent_service
new-item -itemtype directory -force $agent_service_dir > $null
copy-item c:\pkg\extra\dcos-metrics-agent.windows.service "$agent_service"

$agent_public_service="$env:PKG_PATH\dcos.target.wants_slave_public\dcos-metrics-agent.service"
$agent_public_service_dir = Split-Path $agent_public_service
new-item -itemtype directory -force $agent_public_service_dir > $null
copy-item c:\pkg\extra\dcos-metrics-agent.windows.service "$agent_public_service"