# gcp-az-vpn-ha
This is a Terraform script that will build redundant VPN connections between your GCP VPC and Azure VNET, as well as exchange routes via BGP

#### Assumptions
- Given that GCP builds a default auto mode VPC, but Azure really doesn't have a comparable feature, this script assumes we're connecting to the "default" GCP VPC, while we build an Azure Resource Group and VNET in the same script. If you want to connect something else besides the "default" VPC, this can be modified with the "gcp_network" variable, but the network must be already defined in your GCP project. I may change this behavior in a later version, but this is the expected behavior for now.
- BGP is enabled and we dynamically echange all available CIDRs between VPC and VNET.
- I don't really include any means to authenticate to your particular cloud environments. The assumption is you'll add any required credentials to the script.
- See terraform.tfvars for the variable set. I've set some defaults where appropriate, but feel free to modify variables as needed to suit your network build needs for your particular environment.
