<#  Import CSV of Scope information and create new scopes w/ failover relationships and add to sites and services.
    HEADER ROW OF CSV - ScopeName,StartRange,EndRange,SubnetMask,LeaseDuration,Failover,ScopeId,SiteSubnet,Site,SiteLocation,Router
    
    Notes on formatting:
    ScopeName - Name of scope as viewable in DHCP. Also used for description in Sites and Services
    StartRange - First usable IP
    EndRange - Last usable IP
    SubnetMask - xxx.xxx.xxx.xxx format of mask
    LeaseDuration - D.HH:MM:SS
    Failover - Name of preconfigured failover relationship
    ScopeId - Network identifier
    SiteSubnet - Network identifier + CIDR (e.g. 10.0.0.0/24)
    Site - Site code defined in Active Directory
    SiteLocation - Same as ScopeName (description in Sites and Services)
    Router - Default gateway for scope options in DHCP #>

$Data = Import-Csv "Path-to-file.csv"
$DHCPServer = FQDN-OF-DHCP-SERVER


# Create DHCP Scopes

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

$Data | ForEach-Object {

    New-ADReplicationSubnet -Name $_.SiteSubnet -Site $_.Site -Description $_.SiteLocation

}

