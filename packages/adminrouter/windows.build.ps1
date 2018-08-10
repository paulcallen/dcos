$ErrorActionPreference = "stop"

. c:\opt\mesosphere\environment.export.ps1

New-Item -ItemType Directory "$env:PKG_PATH/bin/Apache24/conf"
Copy-Item "/pkg/extra/apache-windows/adminrouter.conf" "$env:PKG_PATH/bin/Apache24/conf"

# Copy service unit file
new-item -ItemType Directory -Force "$env:PKG_PATH\dcos.target.wants"
Copy-Item "c:\pkg\extra\systemd\dcos-adminrouter-agent.windows.service" "$env:PKG_PATH\dcos.target.wants\dcos-adminrouter-agent.service"
