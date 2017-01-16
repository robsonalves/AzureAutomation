
# Create the VM
$vmSize = "Standard_DS2_v2"
$diskSize = 256
$adminCredential = Get-Credential

function CreateVM($server)
{

    #
    # Get-AzureRmVMImagePublisher -Location $location | where "PublisherName" -Like "Microsoft*"
    #  found: MicrosoftWindowsServer

    # Get-AzureRmVMImageOffer -PublisherName MicrosoftWindowsServer -Location $location 
    #  found: WindowsServer
    
    # Get-AzureRmVMImageSku -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Location $location 
    #  found: 2016-Datacenter

    # Get-AzureRmVMImage `
    #    -PublisherName MicrosoftWindowsServer `
    #    -Offer WindowsServer `
    #    -Skus 2016-Datacenter `
    #    -Location $location 

    # Identify the VM Size
    # Get-AzureRmVMSize -Location $location


    # variables
    $baseDiskUri = $premiumStorageUri + "vhd/$server"

    $osDiskUri = "$baseDiskUri-osDisk.vhd"
    $dataDisk1Uri = "$baseDiskUri-dataDisk1.vhd"
    $dataDisk2Uri = "$baseDiskUri-dataDisk2.vhd"

    # 1. Create the template
    $vmConfig = New-AzureRmVMConfig -VMName $server -VMSize $vmSize `
                    -AvailabilitySetId $AVAILABILITY_SET.Id

    # 2. Add OS Disk
    $vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig `
                    -PublisherName "MicrosoftWindowsServer" `
                    -Offer "WindowsServer" `
                    -Skus "2016-Datacenter" `
                    -Version "latest"

    # 3. Configure Windows OS image bootstrap
    $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $server -Credential $adminCredential -ProvisionVMAgent

    # 4. Define the Disk locations (OS + Data)
    $vmConfig = Set-AzureRmVMOSDisk   -VM $vmConfig -Name "osDisk" -VhdUri $osDiskUri -CreateOption FromImage -Caching ReadWrite
    $vmConfig = Add-AzureRmVMDataDisk -VM $vmConfig -Name "dataDisk1" -VhdUri $dataDisk1Uri -Lun 0 -CreateOption Empty -DiskSizeInGB $diskSize -Caching None
    $vmConfig = Add-AzureRmVMDataDisk -VM $vmConfig -Name "dataDisk2" -VhdUri $dataDisk2Uri -Lun 1 -CreateOption Empty -DiskSizeInGB $diskSize -Caching None

    # 5. Add the NIC card(s)
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $ETHERNET.Id 

    # 6. Diagnostics Profile
    $vmConfig = Set-AzureRmVMBootDiagnostics -VM $vmConfig -Enable `
                    -StorageAccountName $diagnosticStorageAccountName `
                    -ResourceGroupName $rg

    # FINALLLY. Create the VM
    $vm = New-AzureRmVM -VM $vmConfig `
                        -ResourceGroupName $rg -Location $location
                        #(optional) DisableBginfoExtension

    return $vm

}

# $vm = Get-AzureRmVM -ResourceGroupName $rg

# Remove-AzureRmVM
# Set-AzureRmVMBginfoExtension  -ResourceGroupName $rg -VMName filesrv01 -Name UpGB -TypeHandlerVersion 2.1
# Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName filesrv01 -Name BGInfo -InformationAction SilentlyContinue

