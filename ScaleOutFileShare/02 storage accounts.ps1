
##########################
# Storage (OS)
##########################
$premiumStorageAccountName = GenerateResourceAccountName  $rg 'premiumstorage'

# Test name availability
#      Get-AzureRmStorageAccountNameAvailability $premiumStorageAccountName
#
$STORAGE = New-AzureRmStorageAccount -Name $premiumStorageAccountName `
                            -SkuName Premium_LRS -Kind Storage `
                            -ResourceGroupName $rg -Location $location  

$premiumStorageUri = $STORAGE.PrimaryEndpoints.Blob

##########################
# Storage (Diagnostics)
##########################
$diagnosticStorageAccountName = GenerateResourceAccountName  $rg 'diagnostic'

$DIAGSTORAGE = New-AzureRmStorageAccount -Name $diagnosticStorageAccountName `
                            -SkuName Standard_LRS -Kind Storage `
                            -ResourceGroupName $rg -Location $location  

$diagnosticStorageUri = $DIAGSTORAGE.PrimaryEndpoints.Blob




$premiumStorageAccountName = GenerateResourceAccountName  $rg 'premiumstorage'                       
$STORAGE = Get-AzureRmStorageAccount $rg $premiumStorageAccountName
$premiumStorageUri = $STORAGE.PrimaryEndpoints.Blob

$diagnosticStorageAccountName = GenerateResourceAccountName  $rg 'diagnostic'
$DIAGSTORAGE = Get-AzureRmStorageAccount $rg $diagnosticStorageAccountName
$diagnosticStorageUri = $DIAGSTORAGE.PrimaryEndpoints.Blob


# Get-AzureRmStorageAccountKey -StorageAccountName $diagnosticStorageAccountName `
#                                -ResourceGroupName $rg

# List ALL storage in Resource Group
#     Get-AzureRmStorageAccount $rg | Format-Table StorageAccountName
