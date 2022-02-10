output "gcp_pubip0" {
  value       = module.vpn_ha.gateway[0].vpn_interfaces[0].ip_address
  description = "GCP Public IP of Tunnel0"
}

output "gcp_pubip1" {
  value       = module.vpn_ha.gateway[0].vpn_interfaces[1].ip_address
  description = "GCP Public IP of Tunnel1"
}

output "az_pubip0" {
  value       =  data.azurerm_public_ip.az_data_pubip0.ip_address
  description = "Azure Public IP of Tunnel0"
}

output "az_pubip1" {
  value       =  data.azurerm_public_ip.az_data_pubip1.ip_address
  description = "Azure Public IP of Tunnel1"
}

output "shared_key" {
  value       =  local.secret_key
  description = "Shared Key for Tunnels"
  sensitive = true
}
