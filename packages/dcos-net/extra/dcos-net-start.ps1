$ErrorActionPreference = "stop"

# Get the ipaddress of this machine
$ipaddress = & c:\opt\mesosphere\bin\detect_ip.ps1
if ($ipaddress -eq "") {
    throw "Failed to get ip address"
    exit -1
}

$name = "navstar@$ipaddress"

# Search the vm.args file and replace ${NAME} with $name if it has not already been replaced
$vmargs = "C:\opt\mesosphere\active\dcos-net\dcos-net\releases\0.0.1\vm.args"
(get-content $vmargs | foreach-object {
	if ($_ -eq '-name ${NAME}') { 
		"-name $name" 
	} else {
		$_
	}
}) | set-content "$vmargs.new"
remove-item $vmargs
rename-item "$vmargs.new" $vmargs

# Some environmental stuff is not quite there yet, so lets install this as an erlang service so it is happy
& C:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net.cmd install 
if ($LASTEXITCODE -ne 0) {
    throw "Failed to run dcos-net.cmd install"
    exit -1
}

& C:\opt\mesosphere\active\dcos-net\dcos-net\erts-9.3\bin\erl.exe -boot C:\opt\mesosphere\active\dcos-net\dcos-net\releases\0.0.1\dcos-net -config C:\opt\mesosphere\active\dcos-net\dcos-net\releases\0.0.1\sys.config -args_file C:\opt\mesosphere\active\dcos-net\dcos-net\releases\0.0.1\vm.args -noshell -noinput +Bd -mode embedded -pa -- foreground
if ($LASTEXITCODE -ne 0) {
    throw "Failed to run erlang command to run dcos-net"
    exit -1
}