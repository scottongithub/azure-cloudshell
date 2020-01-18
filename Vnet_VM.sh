###  make new RG
az group create --name RG_1 --location eastus


###  make new virtual network and subnet
az network vnet create --name VN_1 --resource-group RG_1 --address-prefixes 192.168.51.0/24 --subnet-name SN_1 --subnet-prefixes 192.168.51.0/26 


###  add another subnet for fun
az network vnet subnet create -n SN_2 -g RG_1 --vnet-name VN_1 --address-prefixes 192.168.51.64/26


### look for desktop VMs
az vm image list --location eastus --publisher MicrosoftWindowsDesktop --all --output table


###  create/put VM into this new VNet/subnet - shell will prompt for password
az vm create -n Win_10_1 -g RG_1 --image MicrosoftWindowsDesktop:Windows-10:19h1-pro:18362.476.1911072223 --authentication-type password --size Standard_D2_v2 --location eastus --computer-name Win-10-1 --admin-username scott --vnet-name VN_1 --subnet SN_1


### restrict rdp to just from my workstation's public IP. NSG `Win_10_1NSG` and rule `rdp` was auto-created by `az vm create`
az network nsg rule update -n rdp -g RG_1 --source-address-prefix 1.2.3.4/32 --nsg-name Win_10_1NSG


### get public ip of VM
az network public-ip list -g RG_1


### RDP session should work to it







###### BELOW IS SCRATCH #########









