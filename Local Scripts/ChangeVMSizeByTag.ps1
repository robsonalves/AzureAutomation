<#
    .DESCRIPTION
        This PowerShell runbook changes the size of all VMs which have a specific tag.

    .NOTES
        AUTHOR: Allan Targino
        LASTEDIT: Jan 14, 2017
#>

Function ChangeVMSizeByTag
{
    #Here is the script parameters for repeated tests
    #$TagName = "upgrade";
    #$TagValue = "yes";
    #$NewSize = "Standard_A1";

    Param(
    [Parameter(Mandatory=$true)]
    [String]
    $TagName,
    [Parameter(Mandatory=$true)]
    [String]
    $TagValue,
    [Parameter(Mandatory=$true)]
    [String]
    $NewSize
    )
    Process 
        { 
            Login-AzureRmAccount
            #The Select-AzureRmSubscription only needs to be executed in case you have more than one subscription
            #Select-AzureRmSubscription -SubscriptionId "ENTER HERE YOUR ID"

            Write-Output ("Finding VMs...")
            $vms = Find-AzureRmResource -TagName $TagName -TagValue $TagValue | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}

            Foreach ($vmEntry in $vms){
                # Get the VM object
                $vm = Get-AzureRmVM -Name $vmEntry.Name -ResourceGroupName $vmEntry.ResourceGroupName;
                $oldSize = $vm.HardwareProfile.vmSize;
                #$allowedSizes =  Get-AzureRmVMSize -VMName $vmEntry.Name -ResourceGroupName $vmEntry.ResourceGroupName
            
                If ($oldSize -ne  $NewSize){
                    Write-Output "Trying to change VM size for $($vmEntry.Name)";
                    $vm.HardwareProfile.vmSize = $NewSize
                    Update-AzureRmVM -ResourceGroupName $vmEntry.ResourceGroupName -VM $vm
                    Write-Output "It has been changed from $($oldSize) to $($NewSize)";
                }else{
                    Write-Output "The VM size for $($vmEntry.Name) is the same. The VM size will not be changed.";
                }
            }
            
            Write-Output ("Finished.")
        }
}