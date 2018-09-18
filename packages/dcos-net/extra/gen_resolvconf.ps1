# This file mimics the behaviour on Linux by setting the dns
# lookup addresses on all adapters based on a set of rules:
#
# Always add addresses from $env:SEARCH
# If we can resolve name ready.spartan against dcos-net name server add those addresses
# otherwise add addresses from $env:RESOLVERS

$NAME_SERVERS = @('198.51.100.1', '198.51.100.2', '198.51.100.3')
$dns_test_query = 'ready.spartan'

$search_addresses = @()
# if env variable SEARCH exist, use them
if (test-path env:SEARCH) {
    $search_addresses = $env:SEARCH.Split("{,}")
    $all += $search_addresses
}

$dcos_nets_up = @()
$NAME_SERVERS | ForEach-Object {
    try {
        Resolve-DnsName $dns_test_query -server $_ -ErrorAction Stop

        # if successful add it to the list
        $dcos_nets_up += $_
    } 
    catch {
        write-output "Cannot do name resolve using $_"
    }
}

if ($dcos_nets_up.count -ne 0) {
    # Got some successes so add to list
    $all += $dcos_nets_up
}
else {
    # If we did not get any of our name servers add 
    # the resolvers instead
    $resolver_addresses = $env:RESOLVERS.Split("{,}")
    $all += $resolver_addresses
}

$all_string = $all -join ","

& powershell -file "C:\opt\mesosphere\active\dcos-net\dcos-net\bin\dcos-net-setup.ps1" "SetDnsAddresses" "$all_string" "dcos-net"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to set DNS server addresses"
}
