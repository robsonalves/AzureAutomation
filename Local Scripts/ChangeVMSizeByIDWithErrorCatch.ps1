<#
    .DESCRIPTION
        This PowerShell runbook changes the size of a VM by its ID.

    .NOTES
        AUTHOR: Allan Targino
        LASTEDIT: Jan 23, 2017
#>

Function ChangeVMSizeByIDWithErrorCatch
{
    #Here is the script parameters for repeated tests
    #$VmId = "/subscriptions/SUBSCRIPTIONID/resourceGroups/RGNAME/providers/Microsoft.Compute/virtualMachines/VMNAME";
    #$NewSize = "Standard_A1";

    Param(
    [Parameter(Mandatory=$true)]
    [String]
    $VmId,
    [Parameter(Mandatory=$true)]
    [String]
    $NewSize
    )
    Process 
        { 
            Login-AzureRmAccount
            #The Select-AzureRmSubscription only needs to be executed in case you have more than one subscription
            #Select-AzureRmSubscription -SubscriptionId "ENTER HERE YOUR ID"
            Select-AzureRmSubscription -SubscriptionId "eb6659ac-634f-4460-8e5c-c92db0afcabb"


            Write-Output ("Finding VM...")
            $vmEntry = Get-AzureRmResource -ResourceId $VmId


            # Get the VM object
            $vm = Get-AzureRmVM -Name $vmEntry.Name -ResourceGroupName $vmEntry.ResourceGroupName;
            $oldSize = $vm.HardwareProfile.vmSize;
            #$allowedSizes =  Get-AzureRmVMSize -VMName $vmEntry.Name -ResourceGroupName $vmEntry.ResourceGroupName
            
            If ($oldSize -ne  $NewSize){
                Write-Output "Trying to change VM size for $($vmEntry.Name)";
                Try
                {
                    $vm.HardwareProfile.vmSize = $NewSize
                    Update-AzureRmVM -ResourceGroupName $vmEntry.ResourceGroupName -VM $vm
                    Write-Output "It has been changed from $($oldSize) to $($NewSize)";
                }
                Catch
                {
                    #Write-Output "Error during changing from $($oldSize) to $($NewSize)";
                    $URLLogicApp = "https://prod-05.westus2.logic.azure.com:443/workflows/fe852bfc35544b91a46fb6776bc41eb4/triggers/manual/run?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=fJ7YPMBlZS5-Kai2g6aY4jNEGbk_BB1ZZUbvZAQKmGI"
                    $Err = "Error during changing from $($oldSize) to $($NewSize)";
                    Invoke-WebRequest -Uri $URLLogicApp -Method POST -Body $Err
                    throw "Error during changing from $($oldSize) to $($NewSize)";
                }
            }else{
                Write-Output "The VM size for $($vmEntry.Name) is the same. The VM size will not be changed.";
            }

            
            Write-Output ("Finished.")
        }
}