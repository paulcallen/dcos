$ErrorActionPreference = "stop"
copy-item -recurse "c:\pkg\src\dcos-net\" "c:\"
push-location "c:\dcos-net"

$env:LDFLAGS=" /LIBPATH:c:\opt\mesosphere\lib libsodium.lib "
$env:CFLAGS=" -Ic:\opt\mesosphere\include "
& "${env:ProgramFiles}\erlang\bin\escript" "c:\dcos-net\rebar3" "update"
if ($LASTEXITCODE -ne 0)
{
    throw "failed to update"
}
& "${env:ProgramFiles}\erlang\bin\escript" "c:\dcos-net\rebar3" "as", "windows", "release"
if ($LASTEXITCODE -ne 0)
{
    throw "failed to build"
}

copy-item -Recurse "c:\dcos-net\_build\windows\rel\dcos-net" "$env:PKG_PATH"

new-item -ItemType Directory -Force "$env:PKG_PATH\dcos.target.wants"

# Copy main dcos-net service unit
# Need to fix up the $PKG_PATH environment setting in the windows.service file
$windowsservice = "c:\pkg\extra\dcos-net.windows.service"
$full_path = "${env:PKG_PATH}\dcos-net".replace('/', '\')
(get-content $windowsservice | foreach-object {
    # note: single quotes do not expand variables
	if ($_ -eq 'WorkingDirectory=${PKG_PATH}\dcos-net') { 
        # note: double quotes do expand variables
		"WorkingDirectory=$full_path" 
	} else {
		$_
	}
}) | set-content "$env:PKG_PATH\dcos.target.wants\dcos-net.service"

# Copy watchdog service units
Copy-Item "c:\pkg\extra\dcos-net-watchdog.windows.service" "$env:PKG_PATH\dcos.target.wants\dcos-net-watchdog.service"

# Copy necessary scripts
copy-item "c:\pkg\extra\dcos-net-setup.ps1" "$env:PKG_PATH\dcos-net\bin"
copy-item "c:\pkg\extra\dcos-net-watchdog.py" "$env:PKG_PATH\dcos-net\bin"
Copy-Item "c:\pkg\extra\dcos-net-start.ps1" "$env:PKG_PATH\dcos-net\bin"