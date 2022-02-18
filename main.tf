// local definitions to get us started
// yeah, locals are typically defined in a separate file
// but we only have one ...
locals {
  secret_key = var.tunnel_shared_secret != "" ? var.tunnel_shared_secret : random_string.random_key1.id

}

# Random String Resource
# For use with building a random pre-shared key
# Azure does not work with special chars well here
# so leaving that out, but resulting keys should be
# a 'reasonable' random mix of letters and numbers
resource "random_string" "random_key1" {
  length  = 32
  upper   = true
  special = false
  number  = true
}


resource "google_compute_network" "vpc_network1" {
  count                   = var.gcp_build_vpc ? 1 : 0
  name                    = var.gcp_network
  auto_create_subnetworks = var.gcp_auto_create_subnetworks
  routing_mode            = var.gcp_routing_mode
  // mtu                     = 1460
}

resource "google_compute_subnetwork" "custom_subnets1" {
  for_each      = var.gcp_subnetworks
  name          = "${each.key}-subnet"
  ip_cidr_range = each.value
  region        = each.key
  network       = google_compute_network.vpc_network1[0].id
}


module "vpn_ha" {
  depends_on = [google_compute_network.vpc_network1]
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.gcp_project_id
  region     = var.gcp_region
  network    = var.gcp_network
  name       = var.gcp_gateway_name
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = data.azurerm_public_ip.az_data_pubip0.ip_address

      }, {
      id         = 1
      ip_address = data.azurerm_public_ip.az_data_pubip1.ip_address
    }]
  }
  router_asn = var.gcp_bgp_asn
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = var.az_bgp_apipa_ip0[0] // There should be only one IP in this list for our purpose
        asn     = var.az_bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.gcp_bgp_apipa_ip_nm0
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = local.secret_key

    }
    remote-1 = {
      bgp_peer = {
        address = var.az_bgp_apipa_ip1[0] // There should be only one IP in this list for our purpose
        asn     = var.az_bgp_asn
      }
      bgp_peer_options                = null
      bgp_session_range               = var.gcp_bgp_apipa_ip_nm1
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = local.secret_key
    }
  }
}

// Azure Resources
// Curiously, there is no pre-defined module for a AZ VPN gateway in the public registry
// so I may make one if I get around to it
// for now, we'll just use resource blocks
resource "azurerm_resource_group" "az_rg1" {
  count    = var.az_build_rg ? 1 : 0
  name     = var.az_resource_group_name
  location = var.az_location
}

resource "azurerm_virtual_network" "az_vnet1" {
  depends_on          = [azurerm_resource_group.az_rg1]
  count               = var.az_build_vnet ? 1 : 0
  name                = var.az_vnet_name
  location            = var.az_location
  resource_group_name = var.az_resource_group_name
  address_space       = var.az_vnet_summaries
}

resource "azurerm_subnet" "azrm_gateway_subnet" {
  depends_on = [azurerm_virtual_network.az_vnet1]
  // Hard-coded as "GatewaySubnet" to reserve in AZ for this purpose
  name                 = "GatewaySubnet"
  resource_group_name  = var.az_resource_group_name
  virtual_network_name = var.az_vnet_name
  address_prefixes     = var.az_gateway_subnet
}

resource "azurerm_public_ip" "az_gateway_pubip" {
  depends_on          = [azurerm_resource_group.az_rg1]
  count               = 2
  name                = "az_gateway_pubip${count.index}"
  location            = var.az_location
  resource_group_name = var.az_resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "az_vnet_gateway1" {
  depends_on          = [azurerm_resource_group.az_rg1]
  name                = var.az_vnet_gateway_name
  location            = var.az_location
  resource_group_name = var.az_resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = var.az_vnet_gateway_sku

  bgp_settings {
    asn = var.az_bgp_asn
    peering_addresses {
      ip_configuration_name = "az_gateway_ip0"
      apipa_addresses       = var.az_bgp_apipa_ip0
    }
    peering_addresses {
      ip_configuration_name = "az_gateway_ip1"
      apipa_addresses       = var.az_bgp_apipa_ip1
    }

  }
  ip_configuration {
    name                          = "az_gateway_ip0"
    public_ip_address_id          = azurerm_public_ip.az_gateway_pubip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azrm_gateway_subnet.id
  }
  ip_configuration {
    name                          = "az_gateway_ip1"
    public_ip_address_id          = azurerm_public_ip.az_gateway_pubip[1].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azrm_gateway_subnet.id
  }
}

resource "azurerm_local_network_gateway" "az_peer_gtway" {
  depends_on          = [azurerm_resource_group.az_rg1]
  count               = 2
  name                = "${var.gcp_gateway_name}-peer${count.index}"
  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  gateway_address     = module.vpn_ha.gateway[0].vpn_interfaces[count.index].ip_address

  // We can define specific CIDR's for advertisement to GCP
  // Uncomment below and add your specific prefixes
  // Default behavior is to advertise all CIDRs defined for the VNET
  // address_space       = ["10.1.0.0/16", "169.254.22.24/30"]

  bgp_settings {
    asn                 = var.gcp_bgp_asn
    bgp_peering_address = var.az_bgp_remote_apipa_ip[count.index]
  }
}

resource "azurerm_virtual_network_gateway_connection" "gtway_connection" {
  depends_on                 = [azurerm_resource_group.az_rg1]
  count                      = 2
  name                       = "To-${var.gcp_gateway_name}-${count.index}"
  location                   = var.az_location
  resource_group_name        = var.az_resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_vnet_gateway1.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_peer_gtway[count.index].id
  shared_key                 = local.secret_key

  enable_bgp = true

  // We're using the default IPSec policy here
  // but uncomment below if you need to
  // to set specific cipher selection and/or SA parameters
  /*
  ipsec_policy {
    dh_group                = "DHGROUP2"
    ike_encryption          = "AES256"
    ike_integrity           = "SHA256"
    ipsec_encryption        = "AES256"
    ipsec_integrity         = "SHA256"
    pfs_group               = "None"
    sa_datasize             = 102400000
    sa_lifetime             = 28000
  }
  */
}

// This dirty little trick pulls valid Public IPs from Azure
// when defined as 'dynamic' assignment. Azure DOES NOT assign IPs
// until they are linked to a running resource,so the following in effect
// waits until the VNET gateway is built, THEN extracts the IP's from
// resource once assigned. Whew!
data "azurerm_public_ip" "az_data_pubip0" {
  name                = azurerm_public_ip.az_gateway_pubip[0].name
  resource_group_name = var.az_resource_group_name
  depends_on          = [azurerm_virtual_network_gateway.az_vnet_gateway1]
}

data "azurerm_public_ip" "az_data_pubip1" {
  name                = azurerm_public_ip.az_gateway_pubip[1].name
  resource_group_name = var.az_resource_group_name
  depends_on          = [azurerm_virtual_network_gateway.az_vnet_gateway1]
}