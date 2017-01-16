##########################
# Availability Set
##########################
$service = "cluster"
##########################

$avsetName = "$service-availability"

$AVAILABILITY_SET = New-AzureRmAvailabilitySet -Name $avsetName `
                    -ResourceGroupName $rg -Location $location

##############################################################################
##############################################################################
##############################################################################

$service = "cluster"
$avsetName = "aset-$service"

$AVAILABILITY_SET = Get-AzureRmAvailabilitySet -Name $avsetName -ResourceGroupName $rg