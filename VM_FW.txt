###  make new RG
az group create --name RG_4 --location eastus


###  make new virtual network and subnet
az network vnet create --name VN_4 --resource-group RG_4 --address-prefixes 192.168.54.0/24 --subnet-name SN_4 --subnet-prefixes 192.168.54.0/26


###  create and put put VM into this new VN/subnet - shell will prompt for password
az vm create -n Windows-4 -g RG_4 --image win2019datacenter --authentication-type password --size Standard_D2_v2 --location eastus --computer-name Windows-4 --admin-username scott --vnet-name VN_4 --subnet SN_4 


###  find out NIC name on VM then remove its public IP
az vm nic list --vm-name Windows-4 -g RG_4
az network nic ip-config update -n ipconfigWindows-4 -g RG_4 --nic-name Windows-4VMNic --remove PublicIpAddress 


###  firewall extension does not ship with shell
az extension add -n azure-firewall


###  create firewall
az network firewall create -n FW_4 -g RG_4 --location eastus


###  make NIC for WAN side of firewall
az network public-ip create -n FW_4-PIP -g RG_4 --location eastus --allocation-method static --sku standard


###  firewall needs its own subnet with a minimum /26 
az network vnet subnet create -n AzureFireWallSubnet -g RG_4 --vnet-name VN_4 --address-prefixes 192.168.54.192/26


### give firewall basic network setup and run update - not sure what update does or if necessary
az network firewall ip-config create -n FW_4-config -g RG_4 --firewall-name FW_4 --public-ip-address FW_4-PIP --vnet-name VN_4 --subnet AzureFirewallSubnet
az network firewall update -n FW_4 -g RG_4


###  get firewall's private IP
az network firewall show -n FW_4 -g RG_4


### make routing table/route to route internet traffic from subnet to firewall; apply to the subnet
az network route-table create -n FW_4-RT -g RG_4 --location eastus --disable-bgp-route-propagation
az network route-table route create -n Default -g RG_4 --route-table-name FW_4-RT --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 192.168.54.196
az network vnet subnet update -n SN_4 -g RG_4 --vnet-name VN_4 --address-prefixes 192.168.54.0/26 --route-table FW_4-RT


###  make DNAT rule to take port 55122 from my workstation's public IP and translate to port 3389 on the VM
az network firewall nat-rule create -n RDP-to-Windows-4 -g RG_4 --firewall-name FW_4 --source-address 1.2.3.4 --destination-address 52.151.245.113 --translated-address 192.168.54.4 --destination-ports 55122 --protocols Any --translated-port 3389 --action dnat --collection-name BASIC --priority 300


###  make firewall rule to allow all out from subnet
az network firewall network-rule create -n ALL_OUT -g RG_4 --firewall-name FW_4 --source-address 192.168.54.0/24 --destination-address 0.0.0.0/0 --destination-ports * --protocols Any --action allow --collection-name BASIC --priority 300








###### BELOW IS SCRATCH #########













### secuirty group of NIC needs to allow all out as well...
az network nic update -g RG_4 -n Windows-4-NIC --network-security-group Windows-nsg
az network nsg rule create -g RG_4 --nsg-name Windows-nsg -n AllowAllOut --protocol * --access Allow --direction Outbound --priority 300 --source-address-prefixes 192.168.54.0/24 --destination-address-prefixes Internet --destination-port-ranges *




###  make NIC to be attched to new NM
az network nic create -g RG_4 -n Windows-4-NIC --vnet-name VN_4 --subnet SN_4


###  stop/deallocate VM to replace its default NIC with the new one; replace NIC and start back up
az vm stop -g RG_4 --name Windows-4 
az vm deallocate -g RG_4 --name Windows-4 
az vm nic add --vm-name Windows-4 -g RG_4 --nics Windows-4-NIC
az vm nic remove --vm-name Windows-4 -g RG_4 --nics Windows-4VMNic
az vm start --name Windows-3 -g RG_4





