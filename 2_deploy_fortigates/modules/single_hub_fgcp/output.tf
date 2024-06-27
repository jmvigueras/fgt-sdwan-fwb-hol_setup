# Output
output "hub" {
  value = {
    fgt_mgmt   = "https://${module.hub.fgt_eip_mgmt}:${var.admin_port}"
    fgt_public = module.hub.fgt_eip_public
    username   = "admin"
    password   = module.hub.fgt_id
    admin_cidr = var.admin_cidr
  }
}

output "hub_public_ip" {
  value = module.hub.fgt_eip_public
}

output "hub_bastion_ni" {
  value = aws_network_interface.hub_bastion_ni.id
}

output "hub_fmail_ni" {
  value = aws_network_interface.hub_fmail_ni.id
}
