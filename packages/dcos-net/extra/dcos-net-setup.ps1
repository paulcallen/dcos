# Import full windows  powershell modules that we need. 
# These three work fine with powershell core, although we cannot use the full DnsClient as 
# that has dependencies we do not have, but the subset is all we need.
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetTCPIP\NetTCPIP.psd1
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetAdapter\NetAdapter.psd1
import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\DnsClient\MSFT_DnsClientServerAddress.cdxml

# Add an IP address to the specified adapter if it does not already exist.
# Then add that IP address to all adapters as a DNS lookup address.
function SetLoopbackAdapterAddresses
{
    param($addresses, $mask, $addressFamily, $adapterName) 

    # get adapter, should exist before calling this
    $dcosNetDevice = Get-NetAdapter -Name "$adapterName" -ErrorAction SilentlyContinue
    if(!$dcosNetDevice) {
        Throw "$adapterName adapter was not found"
    }

    # Loop through the addresses
    $addresses | foreach-object {
        # check if address already exists, if so we don't need to do anything
        $existingAddress = Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily $addressFamily -IPAddress $_ -ErrorAction SilentlyContinue
        if($existingAddress) {
            return
        }

        # not currently there so add address to adapter
        New-NetIPAddress -InterfaceAlias $adapterName -AddressFamily $addressFamily -IPAddress $_ -PrefixLength $mask | Out-Null
    }
}

# Add DNS lookup addresses to the specified adapter
function SetDnsAddresses
{
    param($addresses, $adapterName) 
    Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses @($addresses)
}

# add IPv4 addresses to loopback adapter
# args[1] = list of comma separated addresses
# args[2] = address mask
# args[3] = loopback adapter name
if ($args[0] -eq "SetLoopbackAdapterAddresses" )
{
    $addresses = $args[1].Split(",") | ForEach-Object { $_.Trim() }
    SetLoopbackAdapterAddresses -addresses $addresses -mask $args[2] -addressFamily IPv4 -adapterName $args[3]
}
# add IPv6 address to loopback adapter
# args[1] = list of comma separated addresses
# args[2] = address mask
# args[3] = loopback adapter name
elseif ($args[0] -eq "SetLoopbackAdapterAddressesV6")
{
    if ($env:DCOS_NET_IPV6 -ne "true")
    {
        return
    }
    $addresses = $args[1].Split(",") | ForEach-Object { $_.Trim() }
    SetLoopbackAdapterAddresses -addresses $addresses -mask $args[2] -addressFamily IPv6  -adapterName $args[3]
}
# Set the IPv4 DNS server lookup addresses on all adapters
# args[1] = list of comma separated addresses
# args[2] = loopback adapter name
elseif ($args[0] -eq "SetDnsAddresses" )
{
    $addresses = $args[1].Split(",") | ForEach-Object { $_.Trim() }
    SetDnsAddresses -addresses $addresses -adapterName $args[2]
}
# Set the IPv4 DNS server lookup addresses on all adapters
# args[1] = list of comma separated addresses
# args[2] = loopback adapter name
elseif ($args[0] -eq "SetDnsAddressesV6" )
{
    if ($env:DCOS_NET_IPV6 -ne "true")
    {
        return
    }
    $addresses = $args[1].Split(",") | ForEach-Object { $_.Trim() }
    SetDnsAddresses -addresses $addresses -adapterName $args[2]
}
# Add a loop-back adapter if it does not exist
# args[1] = adapter name
elseif ($args[0] -eq "CreateLoopbackAdapter")
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

    Get-NetAdapter | Where-Object { $_.DriverDescription -eq "Microsoft KM-TEST Loopback Adapter" } | Rename-NetAdapter -NewName $args[1]
}