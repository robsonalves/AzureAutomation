
### WARNING!!! NSG is BROKEN

##########################
# Default NSG (Firewall)
##########################
$subnet = "10.0.10.112/28"
$vnetAddressSpace = "10.0.10.0/24"
$vnetName = "vnet"
##########################

$rule = New-AzureRmNetworkSecurityRuleConfig -Name "rdp" -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$NSG = New-AzureRmNetworkSecurityGroup -Name "$vnetName-nsg-default" -SecurityRules $rdpRule `
                                       -ResourceGroupName $rg -Location $location 

##########################
# VNET
##########################
$VNET = New-AzureRmVirtualNetwork -Name $vnetName -AddressPrefix $vnetAddressSpace `
            -ResourceGroupName $rg -Location $location

$vnetSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name default `
                -AddressPrefix $subnet `
                -NetworkSecurityGroupId $nsg.Id

Add-AzureRmVirtualNetworkSubnetConfig -Name default -VirtualNetwork $VNET `
                -AddressPrefix $subnet `
                -NetworkSecurityGroupId $nsg.Id -

$VNET = Set-AzureRmVirtualNetwork -VirtualNetwork $VNET 

$vnetSubnet = $VNET.Subnets | Where { $_.Name -eq "default" }


##############################################################################
##############################################################################
##############################################################################

$subnet = $subnet
$vnetAddressSpace = $vnetAddressSpace
$vnetName = $vnetName 

$NSG = Get-AzureRmNetworkSecurityGroup -Name "vnet-nsg-default" -ResourceGroupName $rg
$VNET = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rg

$vnetSubnet = $VNET.Subnets | Where { $_.Name -eq "default" }


