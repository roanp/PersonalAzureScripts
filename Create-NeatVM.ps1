<#
This script/function is provided AS IS without warranty of any kind. Author(s) disclaim all implied warranties including, without limitation, 
any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall author(s) be 
held liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of 
business information, or other pecuniary loss) arising out of the use of or inability to use the script or documentation.

Based on the below domcumenation 
https://docs.microsoft.com/en-us/powershell/azure/azureps-vm-tutorial?view=azps-5.3.0&tutorial-step=1

#>



#Install the Az module if you haven't done so already.
#Install-Module Az
 
#Login to your Azure account.
#Login-AzAccount
 
#Define the following parameters for the virtual machine.
$vmAdminUsername = "YouLocalAdminUsername"
$vmAdminPassword = ConvertTo-SecureString "YourVMPassowrdwithLostsofSpectialCharcters:-)" -AsPlainText -Force
 
#Define the following parameters for the Azure resources.
$azureLocation              = "australiaeast"
$azureResourceGroup         = "ComputeRG"
$OSazureResourceGRoup       = "StorageRG"
$NICazureResourceGRoup       = "NetworkingRG"
$azureVmName                = "VMNAME"
$vmComputerName             = $azureVmName
$azureVmOsDiskName          = "$azureVmName-OS"
$azureVmSize                = "Standard_B2s"

#Define the existing VNet information.
$azureVnetName              = "Vnet-AE-Test"
$azureVnetSubnetName        = "Subnet-Test"

 
#Define the networking information.
$azureNicName               = "$azureVmName-NIC"
$azurePublicIpName          = "$azureVmName-PIP"

#Define the VM marketplace image details.
$azureVmPublisherName = "MicrosoftWindowsServer"
$azureVmOffer = "WindowsServer"
$azureVmSkus = "2019-Datacenter"
 
#Get the subnet details for the specified virtual network + subnet combination.
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $azureVnetName -ResourceGroupName $NICazureResourceGRoup).Subnets | Where-Object {$_.Name -eq $azureVnetSubnetName}
$azureVnetNSG = (Get-AzNetworkSecurityGroup -ResourceGroupName $azureResourceGroup).Subnets | Where-Object {$_.Name -eq $azureVnetNSG}
 
#Create the public IP address.
$azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName -ResourceGroupName $NICazureResourceGRoup -Location $azureLocation -AllocationMethod Dynamic
 
#Create the NIC and associate the public IpAddress.
$azureNIC = New-AzNetworkInterface -Name $azureNicName -ResourceGroupName $NICazureResourceGRoup -Location $azureLocation -SubnetId $azureVnetSubnet.Id -PublicIpAddressId $azurePublicIp.Id  
 
#Store the credentials for the local admin account.
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)

#Define the parameters for the new virtual machine.
$VirtualMachine = New-AzVMConfig -VMName $azureVmName -VMSize $azureVmSize  # -AvailabilitySetId $vmavailSet.Id
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmComputerName -Credential $vmCredential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $azureNIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
$VirtualMachine = Set-AzVMBootDiagnostic -VM $VirtualMachine -Disable
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine  -StorageAccountType "Standard_LRS" -Caching ReadWrite -Name $azureVmOsDiskName -CreateOption FromImage
 
#Create the virtual machine.
New-AzVM -ResourceGroupName $azureResourceGroup -Location $azureLocation -VM $VirtualMachine -Verbose

#Moving the OS disk to the right resource group.
$Vm = Get-Azvm  -name $azureVmName -resourcegroup $azureResourceGroup  
$DiskName = "$azureVmName-OS"
$disk = $($VM.StorageProfile.OsDisk.Name)
$sourceDisk = Get-AzDisk -ResourceGroup  $azureResourceGroup  -DiskName $disk
$diskConfig = New-AzDiskConfig -SkuNAme $sourcedisk.Sku.Name -location $vm.Location -diskSizeGB  $sourcedisk.diskSizeGB -sourceResourceID $sourceDisk.id -createoption copy
$newOSDisk = New-AzDisk -disk $diskConfig -DiskName $DiskName -ResourceGroup $OSAzureResourceGroup  
Set-AzvmOsDisk -vm $vm -managedDiskId $newOSDisk.ID -Name $DiskName
Update-AzVm -ResourceGroup $resourceGroup -VM $Vm
Remove-AzDisk -resourceGroupNAme $resourceGroup -DiskName $sourceDisk.Name -Force
