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

copy-item -Recurse "c:\dcos-net\_build\windows\rel\dcos-net\*" "$env:PKG_PATH"
#copy-item "c:\pkg\build\extra\*" "$env:PKG_PATH"
