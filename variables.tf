# Input Variables

# GCP Specific VARs
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  nullable    = false
}

variable "gcp_cloud_router" {
  description = "GCP Cloud Router"
  type        = string
  default     = "cloudrouter1"
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}
variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_network" {
  description = "GCP Network Name"
  type        = string
  default     = "default"
}

variable "gcp_bgp_asn" {
  description = "GCP BGP ASN"
  type        = number
}

variable "gcp_gateway_name" {
  description = "GCP Gateway Name"
  type        = string
  default     = "gcp-vpn-Gateway"
}

variable "gcp_tunnel_name" {
  description = "GCP Tunnel Name"
  type        = string
  default     = "gcp-tunnel1"
}

variable "gcp_build_vpc" {
  description = "Build GCP VPC?"
  type        = bool
  default     = false
}

variable "gcp_auto_create_subnetworks" {
  description = "Auto-create Subnetworks?"
  type        = bool
  default     = true
}

variable "gcp_subnetworks" {
  description = "GCP Subnetworks Map (Region = Subnet)"
  type        = map(string)
  default = { }
}

variable "gcp_routing_mode" {
  description = "GCP Routing Mode REGIONAL/GLOBAL"
  type        = string
  default     = "REGIONAL"
}

variable "tunnel_shared_secret" {
  description = "Shared Secret"
  type        = string
  default     = ""
  nullable    = true
}

# Azure Specific Input Variables
variable "az_resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
  default     = "az_rg1"
}

variable "az_location" {
  description = "Azure Location"
  type        = string
  default     = "westus2"
}

variable "az_vnet_name" {
  description = "Azure VNET Name"
  type        = string
  default     = "test"
}

variable "az_vnet_gateway_name" {
  description = "Azure VNET Gateway Name"
  type        = string
  default     = "VNET_Gateway"
}
variable "az_vnet_gateway_sku" {
  description = "Azure VNET Gateway SKU"
  type        = string
  default     = "VpnGw1"
}
variable "az_vnet_summaries" {
  description = "Azure VNET Address Space"
  type        = list(any)
  default     = ["10.0.0.0/16"]
}

variable "az_gateway_subnet" {
  description = "Azure Gateway Subnet"
  type        = list(any)
  default     = ["10.0.0.0/24"]
}

variable "az_bgp_asn" {
  description = "Azure BGP ASN"
  type        = number
  default     = 65515
}
variable "az_bgp_apipa_ip0" {
  description = "Azure BGP APIPA - first tunnel"
  type        = list(any)
}

variable "az_bgp_apipa_ip1" {
  description = "Azure BGP APIPA - second tunnel"
  type        = list(any)
}

variable "gcp_bgp_apipa_ip_nm0" {
  description = "GCP BGP APIPA w/ Netmask - first tunnel"
  type        = string
}

variable "gcp_bgp_apipa_ip_nm1" {
  description = "GCP BGP APIPA w/ Netmask - second tunnel"
  type        = string
}

variable "az_bgp_remote_apipa_ip" {
  description = "Azure Remote VPN IP"
  type        = list(any)
}
