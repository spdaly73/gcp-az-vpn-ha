# gcp-az-vpn-ha
This is a Terraform script that will build redundant VPN connections between your GCP VPC and Azure VNET, as well as exchange routes via BGP

#### Assumptions
- Given that GCP builds a default auto mode VPC, but Azure really doesn't have a comparable feature, this script assumes assumes we're connecting to the "default" GCP VPC, while we build a Azure Resource Group and VNET here. If you want to connect to something else besides the "default" VPC, this can be modified with the "gcp_network" variable, but the network must be already defined in your GCP project. I may change this behavior in a later version, but this is the expected behavior for now.
- BGP is enabled and we dynamically echange all available CIDRs between VPC and VNET.
