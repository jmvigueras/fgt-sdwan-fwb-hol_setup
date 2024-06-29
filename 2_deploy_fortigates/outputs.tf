# Outputs
output "hub_1_mgmt" {
  value = module.dual_hub.hub_1
}
output "hub_2_mgmt" {
  value = module.dual_hub.hub_2
}
output "dual_hub_vpn" {
  value = module.dual_hub.hubs
}

output "r1_users_fgt" {
  value = local.r1_users_fgt
}
output "r2_users_fgt" {
  value = local.r2_users_fgt
}
output "r3_users_fgt" {
  value = local.r3_users_fgt
}
output "users_fgt" {
  value = local.users_fgt
}

#-----------------------------------------------------------------------------------------------------
# Other deployments outputs
#-----------------------------------------------------------------------------------------------------
output "keypair_names" {
  value = {
    r1 = aws_key_pair.r1_keypair.key_name
    r2 = aws_key_pair.r2_keypair.key_name
    r3 = aws_key_pair.r3_keypair.key_name
    hub = aws_key_pair.hub_keypair.key_name
  }
}
output "user_vm_ni_ids" {
  value = {
    r1 = module.r1_users_fgt.user_vm_ni_ids
    r2 = module.r2_users_fgt.user_vm_ni_ids
    r3 = module.r3_users_fgt.user_vm_ni_ids
  }
}
output "user_vm_ni_ips" {
  value = {
    r1 = module.r1_users_fgt.user_vm_ni_ips
    r2 = module.r2_users_fgt.user_vm_ni_ips
    r3 = module.r3_users_fgt.user_vm_ni_ips
  }
}
output "user_fgt_eip_public" {
  value = {
    r1 = module.r1_users_fgt.user_fgt_eip_public
    r2 = module.r2_users_fgt.user_fgt_eip_public
    r3 = module.r3_users_fgt.user_fgt_eip_public
  }
}

output "lab_server_ni" {
  value = module.dual_hub.lab_server_ni
}
output "fmail_ni" {
  value = module.dual_hub.fmail_ni
}