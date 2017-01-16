
function CreateEthernetCard($server)
{
    ##########################
    # Ethernet adapter
    ##########################
    $ipName = "$server-eth-ip"
    $ethName = "$server-eth"

    ##########################
    # Assume: $vnetSubnet = $VNET.Subnets | Where "Name" -EQ "default"
    #

    if ($true)
    {
        $ETHERNET = New-AzureRmNetworkInterface -Name $ethName `
                                                -Subnet $vnetSubnet `
                           -LoadBalancerBackendAddressPool $AZURELB.BackendAddressPools[0] `
                           -ResourceGroupName $rg -Location $location    
    }
    else
    {
        $ETHERNET_IP = New-AzureRmPublicIpAddress -Name $ipName -AllocationMethod Static `
                                               -ResourceGroupName $rg -Location $location                                       

        $ETHERNET = New-AzureRmNetworkInterface -Name $ethName  `
                                                -SubnetId $vnetSubnet.Id `
                                                -ResourceGroupName $rg -Location $location `
                                                -NetworkSecurityGroupId $nsg.Id
                                                -PublicIpAddressId $ETHERNET_IP.Id `
    }

    return $ETHERNET                                   
}

# TODO:
# nat rule
# https://gist.github.com/nmackenzie/54e9fe4bb34f8d6bce2e