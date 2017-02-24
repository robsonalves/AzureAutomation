#######################################################################################
#
# HotSnapshot.ps1 - For Windows Images
#
# This script copies the vhd from a vm creating another vm based on this vhd.
# 
# OBS: The data disks are not included at this copy, only the SO Disk
#  
#
#  Before you use it:
#  - You will need to have accesss to the Storage Name and Key,from both the source and destination Storages;
#  - The also the name of the blob you want to use
#  - It is recommended that you stop the VM that uses the VHD, but it works in most of the times if you don't
#  - if the destination VHD exists the scritpt will stop
#
#  ATTENTION: IF THE DESTINATION MACHINE NAME EXISTS IT WILL BE DELETED TOGETHER WITH NIC,IP AND SO ON, SO PAY ATTENTION!!! 
#######################################################################################

#OStype {Windows | Linux }
$OSType = "Windows"

# Set variable values
$resourceGroupName = "BEMADEMO"
$location = "Brazil South"
$subscriptionName = "DX Brasil"
$vnetName = "BEMADEMO"

#Setup Origin Storage Account (can be the same or different)
$srcStorageAccount = "THE STORAGE NAME"
$srcStorageAccountKey = "THE STORAGE ACCESS KEY"
$srcDiskName = "THE VHD NAME without .VHD"
$srcDiskBlob = "$srcDiskName.vhd"
$srcContainerName = "vhds" 

#New VM 
$vmName = "newmachine"
$vmSize = "Standard_D1"
$nicName = "bemademonic1234"
$dnsName = "bemademo"
$publicIpName = "bemademopubip"
$subnetIndex = 0

#Setup Destination StorageAccount (can be the same or different)
$destStorageAccount = "Storage Acocunt name"
$destStorageAccountKey = "Storage Account key"

#the name of the disk the pattern I'm trying to use is the VMName plus the date
$destDiskName = "$vmName-snap-201702241606"
$destdiskBlob = "$destDiskName.vhd"
$destcontainerName = "vhds"
$destVhdUri = "https://$destStorageAccount.blob.core.windows.net/$destcontainerName/$destdiskBlob"


# login to Azure
Add-AzureRMAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionName


# create backup disk if it doesn't exist
#Source Context
$srcContext  = New-AzureStorageContext -StorageAccountName $destStorageAccount -StorageAccountKey $destStorageAccountKey

# Destination Context
$destContext = New-AzureStorageContext –StorageAccountName $srcStorageAccount  -StorageAccountKey $srcStorageAccountKey 

if ($containerCount -eq 0)
{
    New-AzureStorageContainer -Name $containerName -Context $destContext
}

#verify if the blob already existis
$blobCount = Get-AzureStorageBlob -Container $destcontainerName -Context $destContext | where { $_.Name -eq $destdiskBlob } | Measure | % { $_.Count }

if ($blobCount -eq 1)
{
    echo "The destination blob $destdiskBlob already exists"
    exit -1
}
else
{

  $copy = Start-AzureStorageBlobCopy -SrcContainer $srcContainerName  -SrcBlob $srcDiskBlob -SrcContext $srcContext `
                                    -DestContainer $destcontainerName -DestBlob $destdiskBlob -DestContext $destContext

  #Show status of the operation
  $status = $copy | Get-AzureStorageBlobCopyState 
  $status 
  While($status.Status -eq "Pending"){
    $status = $copy | Get-AzureStorageBlobCopyState 
    Start-Sleep 1
    $status
  }
}


#prior to create a newVM we will stop the VM with the given name
#if the desination VM existis it will be deleted and created again with the new VHD
Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force -Verbose


# delete VM (ensure that the name of the resources provided isnot been in use)
#TODO - Check if the item exists before delete
Remove-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force -Verbose
Remove-AzureRmStorageBlob -Blob $destdiskBlob -Container $destcontainerName -Context $destContext -Verbose
Remove-AzureNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Force -Verbose
Remove-AzurePublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Force -Verbose

# recreate VM
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName

$pip = New-AzureRmPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -DomainNameLabel $dnsName -Location $location -AllocationMethod Dynamic -Verbose
$nic = New-AzureRMNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[$subnetIndex].Id -PublicIpAddressId $pip.Id -Verbose
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

if ($OSType -eq "Windows"){
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $destDiskName -VhdUri $destVhdUri -CreateOption attach -Windows
}else{
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $destDiskName -VhdUri $destVhdUri -CreateOption attach -Linux
}

New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm -Verbose
