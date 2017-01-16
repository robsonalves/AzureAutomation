Install-WindowsFeature Failover-Clustering -IncludeManagementTools 

$nodes = ("SRV01", "SRV02")

Test-Cluster -node $nodes -Include "Storage Spaces Direct",Inventory,Network,"System Configuration" 

new-cluster -name democluster -node $nodes -nostorage -staticaddress 192.168.1.100 -AdministrativeAccessPoint DNS 

enable-clusters2d -verbose

New-Volume -StoragePoolFriendlyName S2D* -FriendlyName MultiResilient -FileSystem CSVFS_REFS -StorageTierFriendlyName Capacity -StorageTierSizes 150GB

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "SRV03, SRV02"

new-itemproperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1

Set-ClusterQuorum -CloudWitness -AccountName <> -AccessKey <> 
