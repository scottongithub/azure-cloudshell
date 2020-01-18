# Overview

A collection of projects created in Azure CloudShell for study purposes

* `Vnet_VM` makes a resource-group, v-net, subnet, then throws a VM into it that listens for *only* RDP and *only* from a specific address (1.2.3.4)

* `VM_FW` makes a RG and puts the following into it: networking, firewall, and VM. Rules and routing are created so that *only* RDP can reach the VM and *only* via port 55122 to a firewall NIC and from a specific public address (1.2.3.4)

# Notes

Azure Firewall costs $3/hr/instance so there's that. Though it has the option to allow 'all' layer-4 protocols in its rules, it does not forward anything other than TCP/UDP and does not consume anything from the data plane e.g. you cannot ping *to* or *through* it. It does seem a bit silly that an in-line network appliance doesn't speak ICMP with its data plane - corrections are welcomed and appreciated
