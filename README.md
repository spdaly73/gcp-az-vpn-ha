# gcp-az-vpn-ha
This is a Terraform script that builds redundant VPN connections between your GCP VPC and Azure VNET, as well as exchange routes via BGP

#### Disclaimer
I'm still very much a novice (IMO) when it comes to Terraform, so if you see something amiss, feel free to let me know. The main point of building this script is for my personal IaC development and training, so constructive direction is appreciated.

#### Assumptions
- Given that GCP builds a default auto mode VPC, but Azure really doesn't have a comparable feature, this script assumes we're connecting to the "default" GCP VPC, while we build an Azure Resource Group and VNET in the same script. If you want to connect something else besides the "default" VPC, this can be modified with the "gcp_network" variable, but the network must be already defined in your GCP project. I may change this behavior in a later version, but this is the expected behavior for now.
- BGP is enabled and we dynamically echange all available CIDRs between VPC and VNET.
- I don't include any means to authenticate to your particular cloud environments. The assumption is you'll add any required credentials to the script.

#### Compatibility
This script has been tested with the following provider/module versions:
- Terraform: = 1.1.3
- Azurerm: >= 2.91, <= 2.95
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
- See terraform.tfvars for the variable set, in which I think should be fairly self-explanitory. I've set some defaults where appropriate, but feel free to modify variables as needed to suit your network build needs for your particular environment.

#### Outputs
- gcp_pubip0: GCP Public IP of Tunnel0
- gcp_pubip1: GCP Public IP of Tunnel1
- az_pubip0: Azure Public IP of Tunnel0
- az_pubip1: Azure Public IP of Tunnel1
- shared_key: Shared key used to authenticate tunnels (sensitive=true)

#### Version - This Script
- Current: v0.1

#### Misc
I'm a little surpised that I didn't find an Azure VPN module in the Terraform Registry, so I'm considering creating one for my next 'project'. For now, I'm using base Azure RM resource blocks; see comments in main.tf for further banter/nonsense.
