# gcp-az-vpn-ha
This is a Terraform script that builds redundant VPN connections between your GCP VPC and Azure VNET, as well as exchange routes via BGP

#### Disclaimer
I'm still very much a novice (IMO) when it comes to Terraform, so if you see something amiss, feel free to let me know. The main point of building this script is for my personal IaC development and training, so constructive direction is appreciated.

#### Assumptions
- Given that GCP builds a default auto mode VPC, but Azure really doesn't have a comparable feature, this script assumes we're connecting to the "default" GCP VPC, while we build an Azure Resource Group and VNET in the same script. However, this default behavior can now be modified, see variable definitions below.
- BGP is enabled and we dynamically exchange all available CIDRs between VPC and VNET.
- I don't include any means to authenticate to your particular cloud environments (nor would or should I know this). The assumption is you'll add any required credentials to the script.

#### Compatibility
This script has been tested with the following provider/module versions:
- Terraform: = 1.1.3
- Azurerm: = 2.91, = 2.93, = 2.96  (do not use with 2.95, the script breaks with this version)
- Google, Google-beta: = 4.10
- Random (for shared secret generation): = 3.1
- terraform-google-modules/modules/vpn_ha: = 2.2  https://github.com/terraform-google-modules/terraform-google-vpn/tree/master/modules/vpn_ha

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
| az_bgp_apipa_ip0 | IP Address of Azure Tunnel0 | list(string) (should be a single list item) | "169.254.21.2" | N |
| az_bgp_apipa_ip1 | IP Address of Azure Tunnel1 | list(string) (should be a single list item) | "169.254.21.6" | N |







#### Outputs
- gcp_pubip0: GCP Public IP of Tunnel0
- gcp_pubip1: GCP Public IP of Tunnel1
- az_pubip0: Azure Public IP of Tunnel0
- az_pubip1: Azure Public IP of Tunnel1
- shared_key: Shared key used to authenticate tunnels (sensitive=true)

#### Version - This Script
- Current: v0.2 - Added functionality to create new GCP VPC and/or Azure VNET if specific variables are set (see inputs section)
- v0.1.1 - sucessfully tested with AzureRM 2.96, so this provider version has been updated
- v0.1 - original script

#### Misc
I'm a little surpised that I didn't find an Azure VPN module in the Terraform Registry, so I'm considering creating one for my next 'project'. For now, I'm using base Azure RM resource blocks; see comments in main.tf for further banter/nonsense.
