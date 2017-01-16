
$server = "srv01001"

$ETHERNET = CreateEthernetCard $server
$VM = CreateVM $server

Get-AzureRmVM | Format-Table