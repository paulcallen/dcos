$ErrorActionPreference = "stop"

# just copy the run-time out of the container
new-item -ItemType Directory "$env:PKG_PATH\bin" -ErrorAction SilentlyContinue > $null
copy-item "$env:programfiles\erlang\erts-9.3\bin\*" "$env:PKG_PATH\bin\"