# Import CSV of Scope information and create new scopes w/ failover relationships and add to sites and services.

$Data = Import-Csv "Path-to-file.csv"
$DHCPServer = FQDN-OF-DHCP-SERVER


# Create scopes (LeaseDuration in day.hrs:mins:secs)
### NEED TO ADD SCOPE OPTION FOR DEFAULT GATEWAY ###
### ADD TARGET SERVER ###

$Data | ForEach-Object {

    Add-DhcpServerv4Scope -ComputerName $DHCPServer -Name $_.ScopeName -StartRange $_.StartRange -EndRange $_.EndRange -SubnetMask $_.SubnetMask -LeaseDuration $_.LeaseDuration

}

# Add scope options prior to failover relationship

$Data | ForEach-Object {

    Set-DhcpServerv4OptionValue -ComputerName $DHCPServer -ScopeId $_.ScopeId -Router $_.Router

}

# Add scopes to failover relationship

$Data | ForEach-Object {

    Add-DhcpServerv4FailoverScope -ComputerName $DHCPServer -Name $_.Failover -ScopeId $_.ScopeId

}

# Add scopes to sites and services
### CHANGE LOCATION TO DESCRIPTION ###

$Data | ForEach-Object {

    New-ADReplicationSubnet -Name $_.SiteSubnet -Site $_.Site -Description $_.SiteLocation

}

