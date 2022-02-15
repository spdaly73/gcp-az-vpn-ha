// GCP Specific VARs
gcp_project_id = "your-gcp-project-id-here"
gcp_region     = "us-west1"
gcp_zone       = "us-west1-b"
// Only lowercase letters, numbers, hyphens allowed for GCP network name
gcp_network = "default"
// If the above network is not currently defined, let's try and build it
// but its recommended that we use a VPC already built.
gcp_build_vpc = false
gcp_auto_create_subnetworks = true
// Set below only if you want to create custom subnets within your newly created VPC
// Otherwise, leave as an empty map (default). Eg:
// gcp_subnetworks = {
//  "us-west1" = "10.6.0.0/23"
//  "us-central1" = "10.6.2.0/23"
//  "us-west2" = "10.6.4.0/22"
// }
gcp_subnetworks = { }

// The following can be set "REGIONAL" or "GLOBAL"
// If REGIONAL, cloud router only advertises networks in the region in which it's built
// Of GLOBAL, advertises all CIDRs known to the VPC
// Only applies if building a new VPC, otherwise we're taking the settings already set
// in the existing VPC
gcp_routing_mode = "GLOBAL"
gcp_bgp_asn = 64519
// Only lowercase letters, numbers, hyphens allowed for next set of strings
gcp_cloud_router = "gcp-cloudrouter1"
gcp_gateway_name = "gcp-vpn-gateway"
gcp_tunnel_name  = "gcp-tunnel"

// Azure prefers (requires?) using APIPA addressing within the 169.254.21.0/24
// and 169.254.22.0/24 address space when using BGP, so we'll define APIPA variables here
gcp_bgp_apipa_ip_nm0 = "169.254.21.1/30"
gcp_bgp_apipa_ip_nm1 = "169.254.21.5/30"

// This is an ordered list of the 2 variables above w/out the Netmask
// I guess I could've massaged the strings above, but hey, I'm being lazy at the moment...
az_bgp_remote_apipa_ip = ["169.254.21.1", "169.254.21.5"]

// Azure is showing to be able to configure multiple BGP neighbors per tunnel
// But we only need one,
// so there should be only one IP in each of the the next two lists for our purposes
az_bgp_apipa_ip0 = ["169.254.21.2"]
az_bgp_apipa_ip1 = ["169.254.21.6"]

// Azure Specific Resource Variables
az_build_rg = true
// If above variable set to false, the following var must match the name of a VNET already built
az_resource_group_name = "azrm_rg1"
az_location            = "westus2"

az_build_vnet = true
// If above variable set to false, the following var must match the name of a VNET already built
az_vnet_name           = "vnet1"
az_vnet_summaries      = ["10.1.0.0/16"]

az_gateway_subnet      = ["10.1.1.0/27"]
az_vnet_gateway_name   = "vnet1_gateway"
az_bgp_asn             = 65515

// See https://azure.microsoft.com/en-us/pricing/details/vpn-gateway/
// for SKU options. Because we're using BGP, "Basic" cannot be used.
// Curiously, I get an error when I use 'AZ' (zone redundant)
// SKU's here. One would think we would prefer this for an 'Active-Active'
// gateway?
// "VpnGw1" is the smallest SKU for our circumstance, so it's set as the default
az_vnet_gateway_sku = "VpnGw1"

// You can set a shared key here, or leave blank to have keys randomly generated
tunnel_shared_secret = ""