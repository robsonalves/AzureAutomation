##########################
# Login
##########################

Login-AzureRmAccount

Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 58584b3f-09b6-4f4c-ba97-33da14e1b959

##########################
# Resource Group
##########################
$rg = "fileserver"
$location = "eastus"
##########################

New-AzureRmResourceGroup -Name $rg -Location $location

##########################
# Create Function
##########################
function GenerateResourceAccountName ([string]$resourceGroup, [string]$resourceName)
{ 
    $seed1 = ($resourceGroup + $resourceName).GetHashCode()
    $seed2 = ($resourceName).GetHashCode()
    
    $validChars = "abcdefghijkmnopqrstuvwxyz"
    $validNumbers = "0123456789"
    
    function GeneratorXYZ([string]$charRange, [int]$count, [int]$seed) {
        
        $chars = Get-Random -InputObject $charRange.ToCharArray() -Count $count -SetSeed $seed
        return $chars -join ""        
    }

    # $sufix = [DateTime]::UtcNow.ToString("yyyyMMdd")
    
    "{0}{1}{2}" -f `
        (GeneratorXYZ $validChars 3 $seed1), `
        (GeneratorXYZ $validNumbers 3 $seed2), `
        $resourceName    
}


##############################################################################
##############################################################################
##############################################################################

$rg = $rg
$location = $location

GenerateResourceAccountName

Get-AzureRmResourceGroup -Name $rg

