// GCP Specific VARs
gcp_project_id = "your-project-id-goes-here"
gcp_region     = "us-west1"
gcp_zone       = "us-west1-b"
// we're assuming this VPC has already been created...
gcp_network = "default"
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
az_resource_group_name = "azrm_resource_group1"
az_location            = "westus2"
az_vnet_name           = "my_vnet1"
az_vnet_summaries      = ["10.1.0.0/16"]
az_gateway_subnet      = ["10.1.0.0/24"]
az_vnet_gateway_name   = "vnet_gateway"
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
