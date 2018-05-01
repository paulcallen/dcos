$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1

new-item -itemtype Directory "$env:PKG_PATH/dcos.target.wants_slave"
copy-item "/pkg/extra/systemd/dcos-adminrouter-agent.windows.service" "$env:PKG_PATH/dcos.target.wants_slave/dcos-adminrouter-agent.service"

new-item -itemtype Directory "$env:PKG_PATH/dcos.target.wants_slave_public"
copy-item "/pkg/extra/systemd/dcos-adminrouter-agent.windows.service" "$env:PKG_PATH/dcos.target.wants_slave_public/dcos-adminrouter-agent.service"

New-Item -ItemType Directory "$env:PKG_PATH/bin/Apache24/conf"
Copy-Item "pkg/extra/apache-windows/adminrouter.conf" "$env:PKG_PATH/bin/Apache24/conf"
