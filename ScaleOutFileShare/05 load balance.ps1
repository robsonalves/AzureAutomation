
##########################
$serviceDns = "dnsname"
$probeTcpPort = 445
##########################

# public IP
$VIRTUALIP = New-AzureRmPublicIpAddress -Name "$service-virtual-ip" `
                -AllocationMethod Static -DomainNameLabel $serviceDns `
                -ResourceGroupName $rg -Location $location 

$frontConfig = New-AzureRmLoadBalancerFrontendIpConfig -Name "frontend" -PublicIpAddress $VIRTUALIP

$backConfig= New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "backpool"

$lbprobe = New-AzureRmLoadBalancerProbeConfig -Name "TcpProbe" `
                -Protocol tcp -Port $probeTcpPort -IntervalInSeconds 5 -ProbeCount 2

$rule = New-AzureRmLoadBalancerRuleConfig -Name "SMB" `
   -FrontendIpConfiguration $frontConfig -BackendAddressPool $backConfig `
   -Probe $lbprobe -Protocol Tcp -FrontendPort 445 -BackendPort 445

$AZURELB = New-AzureRmLoadBalancer -Name "$service-loadbalance" `
   -FrontendIpConfiguration $frontConfig `
   -BackendAddressPool $backConfig `
   -Probe $lbprobe `
   -LoadBalancingRule $rule `
   -ResourceGroupName $rg -Location $location 


##############################################################################
##############################################################################
##############################################################################

$serviceDns = "fileload445"
$probeTcpPort = 445

$VIRTUALIP = Get-AzureRmPublicIpAddress -Name "$service-virtual-ip" -ResourceGroupName $rg 
$AZURELB = Get-AzureRmLoadBalancer -Name "$service-loadbalance" -ResourceGroupName $rg



# private IP
$AZURELB = Get-AzureRmLoadBalancer -Name "lb-$service" -ResourceGroupName $rg
$frontConfig = New-AzureRmLoadBalancerFrontendIpConfig -Name "frontend" -PrivateIpAddress 10.0.0.200 -Subnet $vnetSubnet

$azurelb2 = Add-AzureRmLoadBalancerFrontendIpConfig -Name "internal-front" -LoadBalancer $AZURELB -PrivateIpAddress 10.0.0.200 -Subnet $vnetSubnet 
   

$AZURELB.FrontendIpConfigurations.Add (  $frontConfig)

Set-AzureRmLoadBalancer -LoadBalancer $azurelb2

$set = Set-AzureRmLoadBalancer -LoadBalancer $azurelb2
