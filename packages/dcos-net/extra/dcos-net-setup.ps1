# Import full windows  powershell modules that we need. 
# These three work fine with powershell core, although we cannot use the full DnsClient as 
# that has dependencies we do not have, but the subset is all we need.
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetTCPIP\NetTCPIP.psd1
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetAdapter\NetAdapter.psd1
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\DnsClient\MSFT_DnsClientServerAddress.cdxml

# Add an IP address to the specified adapter if it does not already exist.
# Then add that IP address to all adapters as a DNS lookup address.
function AddDnsAddress
{
    param($address, $mask, $addressFamily, $adapterName) 

    # get adapter
    $dcosNetDevice = Get-NetAdapter -Name "$adapterName" -ErrorAction SilentlyContinue
    if(!$dcosNetDevice) {
        Throw "$adapterName adapter was not found"
    }

    # check if address already exists, if so we don't need to do anything
    $existingAddress = Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily $addressFamily -IPAddress $address -ErrorAction SilentlyContinue
    if($existingAddress) {
        return
    }

    # not currently there so add address to adapter
    New-NetIPAddress -InterfaceAlias $adapterName -AddressFamily $addressFamily -IPAddress $address -PrefixLength $mask | Out-Null

    # new DNS address, so add new address to all adapters, before any existing addresses that may already exist
    Get-DnsClientServerAddress -AddressFamily $addressFamily | foreach-object {
        # only add if address is not already in the list
        if ($_.ServerAddresses -notcontains $address) {
            Set-DnsClientServerAddress -InterfaceAlias $_.InterfaceAlias  -ServerAddresses @($address, $_.ServerAddresses)
        }
    }
}

# add IPv4 address to adapter and add as DNS address to all adapters
#ExecStartPre=c:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1 ip-addr-add 198.51.100.1 32 dcos-net
#ExecStartPre=c:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1 ip-addr-add 198.51.100.2 32 dcos-net
#ExecStartPre=c:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1 ip-addr-add 198.51.100.3 32 dcos-net
if ($args[0] -eq "ip-addr-add" )
{
    AddDnsAddress -address $args[1] -mask $args[2] -addressFamily IPv4 -adapterName $args[3]
}
# add IPv6 address to adapter and add as DNS address to all adapters
#ExecStartPre=c:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1 ip-addr-add-ipv6 fd01:d::c633:6401 128 dcos-net
elseif ($args[0] -eq "ip-addr-add-ipv6")
{
    if ($env:DCOS_NET_IPV6 -ne "true")
    {
        return
    }
    AddDnsAddress -address $args[1] -mask $args[2] -addressFamily IPv6  -adapterName $args[3]
}
# Add a loop-back adapter if it does not exist
#ExecStartPre=c:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1 ip-link-add dcos-net
elseif ($args[0] -eq "ip-link-add")
{
    # First check to see if it is already installed...
    $dcosNetDevice = Get-NetAdapter -Name $args[1] -ErrorAction SilentlyContinue
    if ($dcosNetDevice.count -ne 0)
    {
        # Already there!
        return
    }

    & curl.exe -fLsS -o "$env:tmp\devcon.cab" "https://download.microsoft.com/download/7/D/D/7DD48DE6-8BDA-47C0-854A-539A800FAA90/wdk/Installers/787bee96dbd26371076b37b13c405890.cab"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to download windows windows driver kit"
    }
    & expand.exe "$env:tmp\devcon.cab" "-F:filbad6e2cce5ebc45a401e19c613d0a28f" "$env:tmp"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to extract devcon.exe binary from windows driver kit"
    }
    Move-Item "$env:tmp\filbad6e2cce5ebc45a401e19c613d0a28f" "$env:tmp\devcon.exe"
    & "$env:tmp\devcon.exe" "install" "${env:windir}\Inf\Netloop.inf" "*MSLOOP"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to run devcon.exe to install a loopback network adapter"
    }
    remove-item "$env:tmp\devcon.cab" -ErrorAction Ignore
    remove-item "$env:tmp\devcon.exe" -ErrorAction Ignore

    Get-NetAdapter | Where-Object { $_.DriverDescription -eq "Microsoft KM-TEST Loopback Adapter" } | Rename-NetAdapter -NewName "dcos-net"
}