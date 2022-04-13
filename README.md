# gcp-az-vpn-ha
This is a Terraform script that builds redundant VPN connections between your GCP VPC and Azure VNET, as well as exchange routes via BGP

#### Disclaimer
The main point of building this script is for my personal IaC development and training, so constructive direction is appreciated.

#### Assumptions
- Given that GCP builds a default auto mode VPC, but Azure really doesn't have a comparable feature, this script assumes we're connecting to the "default" GCP VPC, while we build an Azure Resource Group and VNET in the same script. However, this default behavior can now be modified, see variable definitions below.
- BGP is enabled and we dynamically exchange all available CIDRs between VPC and VNET.
- You'll add any required credentials to the script.

#### Compatibility
This script has been tested with the following provider/module versions:
- Terraform: = 1.1.3
- Azurerm: = 2.91, = 2.93, = 2.96  (do not use with 2.95, the script breaks with this version)
- Google, Google-beta: = 4.10
- Random (for shared secret generation): = 3.1
- [terraform-google-modules/modules/vpn_ha](https://github.com/terraform-google-modules/terraform-google-vpn/tree/master/modules/vpn_ha) : = 2.2

#### Files
- /providers.tf: Provider blocks.
- /variables.tf: Variable definitions.
- /main.tf: Primary script.
- /outputs.tf: Yes, as a matter of fact, output definitions live here.
- /terraform.tfvars: User-defined variables.
- /README.md: The file that you're reading right now.

#### Usage
- See terraform.tfvars for the variable set, see descriptions below. I've set some defaults where appropriate, but feel free to modify variables as needed to suit your network build for your particular environment.

#### Inputs

| Variable Name | Description | Type | Default | Required? |
| --- | --- | --- | --- | --- |
| gcp_project_id | GCP Project ID | string | n/a | Y |
| gcp_region | GCP Region | string | "us-central1" | N |
| gcp_zone | GCP Zone (must be a valid zone within the region defined above) | string | "us-central1-a" | N |
| gcp_network | GCP VPC name in which the Cloud VPN and router will be built | string | "default" | N |
| gcp_build_vpc | Instruct Terraform to build the GPC VPC defined above (if not already built) | bool | false | N |
| gcp_auto_create_subnetworks | Auto-create GCP subnetworks if building a new VPC | bool | true | N |
| gcp_subnetworks | Defines custom GCP subnetworks if building a new VPC | map(string) { "region" = "subnet" } | empty set { } | N |
| gcp_routing_mode | Defines REGIONAL or GLOBAL routing mode if building new VPC | string | "REGIONAL" | N |
| gcp_bgp_asn | GCP BGP ASN (See GCP docs for valid private ASN options) | number | 64519 | N |
| gcp_cloud_router | Name of your GCP Cloud Router | string | "gcp-cloud-router" | N |
| gcp_gateway_name | Name of your GCP VPN Gateway | string | "gcp-vpn-gateway" | N |
| gcp_tunnel_name | Prefix naming for your GCP tunnel endpoints | string | "gcp-tunnel-" | N |
| gcp_bgp_apipa_ip_nm0 | APIPA w/ netmask assigned to GCP tunnel0 | string | "169.254.21.1/30" | N |
| gcp_bgp_apipa_ip_nm1 | APIPA w/ netmask assigned to GCP tunnel1 | string | "169.254.21.5/30" | N |
| az_bgp_remote_apipa_ip | Represents a list of the above two strings without a netmask | list(string) | ["169.254.21.1", "169.254.21.5"] | N |
| az_bgp_apipa_ip0 | IP Address of Azure Tunnel0 | list(string) (should be a single list item) | ["169.254.21.2"] | N |
| az_bgp_apipa_ip1 | IP Address of Azure Tunnel1 | list(string) (should be a single list item) | ["169.254.21.6"] | N |
| az_resource_group_name | Azure Resource Group Name | string | "azrm_rg1" | N |
| az_build_rg | Instruct Terraform to build the Azure Resource Group defined above (if not already built) | bool | true | N |
| az_vnet_name | Azure VNET in which the gateway resources will be built | string | "vnet1" | N |
| az_build_vnet | Instruct Terraform to build the Azure VNET defined above (if not already built) | bool | true | N |
| az_location | Azure Region in which resources will be built | string | "westus2" | N |
| az_vnet_summaries | CIDRs defined within Azure VNET (if not already built) | list(string) | ["10.64.0.0/16", "10.65.0.0/16"] | N |
| az_gateway_subnet | subnet reserved for Azure gateway (must be within VNET summary) | list(string) (should be a single list item) | ["10.64.255.0/24"] | N |
| az_vnet_gateway_name | Azure VNET Gateway Name | string | "vnet1_gateway" | N |
| az_bgp_asn | Azure BGP ASN (See Azure docs for valid private ASN options) | number | 65515 | N |
| az_vnet_gateway_sku | Azure SKU for gateway sizing and bandwidth | string | "VpnGw1" | N |
| tunnel_shared_secret | Shared key between cloud providers to authenticate IPSec tunnels (Random string generated is left blank) | string | "" | N |

#### Outputs
| Variable Name | Description |
| --- | --- |
| gcp_pubip0 | GCP Public IP of Tunnel0 |
| gcp_pubip1 | GCP Public IP of Tunnel1 |
| az_pubip0 | Azure Public IP of Tunnel0 |
| az_pubip1 | Azure Public IP of Tunnel1 |
| shared_key | Shared key used to authenticate tunnels (sensitive=true) | string |

#### Version - This Script
- Current: v0.2 - Added functionality to create new GCP VPC and/or Azure VNET if specific variables are set (see inputs section)
- v0.1.1 - sucessfully tested with AzureRM 2.96, this version has been updated in the provider block. Script also confirmed broken in Azure v2.95, do not use this version.
- v0.1 - original script

#### Related Docs
- https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways
- https://cloud.google.com/network-connectivity/docs/vpn/concepts/overview

#### Misc
See comments in the code for further banter/nonsense/explanations/direction.
