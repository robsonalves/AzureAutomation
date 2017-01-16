Install-WindowsFeature FS-FileServer

Get-ClusterSharedVolume

Install-WindowsFeature FS-FileServer -IncludeManagementTools

Add-ClusterScaleOutFileServerRole -Name FShare -Cluster democluster

New-Item -Path C:\ClusterStorage\Data\VOL1 -ItemType Directory
New-SmbShare -? -Name WindowsFiles -Path C:\ClusterStorage\Data\VOL1
Grant-SmbShareAccess –Name WindowsFiles –AccountName srv02\fabricio –AccessRight Full

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "SRV01, SRV02, FSHARE"