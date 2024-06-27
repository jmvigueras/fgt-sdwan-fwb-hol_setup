# Output
output "user_fgts" {
  value = { for k, v in module.user : k => 
    {
      fgt_mgmt    = "https://${v.fgt_eip_mgmt}:${var.admin_port}"
      fgt_public  = v.fgt_eip_public
      fgt_api_key = var.api_key
      username    = "admin"
      password    = v.fgt_id
      admin_cidr  = var.admin_cidr
    }
  }
}

output "user_fgt_eip_public" {
  value = { for k, v in module.user : k => v.fgt_eip_public }
}

output "user_vm_ni_ids" {
  value = { for k, v in aws_network_interface.user_vm_ni : k => v.id }
}

output "user_vm_ni_ips" {
  value = { for k, v in local.spokes_sdwan : k => cidrhost(module.user_vpc[k]["subnet_az1_cidrs"]["bastion"], 10) }
}