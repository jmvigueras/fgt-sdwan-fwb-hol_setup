#-----------------------------------------------------------------------------------------------------
# HUB 1
#-----------------------------------------------------------------------------------------------------
output "hub_1" {
  value = {
    fgt1_mgmt = "https://${one(module.hub_1_nis.fgt_ni_list["az1.fgt1"]["public_eips"])}:${var.admin_port}"
    fgt2_mgmt = "https://${one(module.hub_1_nis.fgt_ni_list["az2.fgt1"]["public_eips"])}:${var.admin_port}"
    fgt_user  = "admin"
    fgt1_pwd  = element(module.hub_1.fgt_list, 0).id
    fgt2_pwd  = element(module.hub_1.fgt_list, 1).id
  }
}
output "hub_1_spoke_to_tgw_vm" {
  value = { for k, v in module.hub_1_spoke_to_tgw_vm : k => v.vm }
}

#-----------------------------------------------------------------------------------------------------
# HUB 2
#-----------------------------------------------------------------------------------------------------
output "hub_2" {
  value = {
    fgt1_mgmt   = "https://${one(module.hub_2_nis.fgt_ni_list["az1.fgt1"]["mgmt_eips"])}:${var.admin_port}"
    fgt2_mgmt   = "https://${one(module.hub_2_nis.fgt_ni_list["az2.fgt1"]["mgmt_eips"])}:${var.admin_port}"
    fgt_user    = "admin"
    fgt1_pwd    = element(module.hub_2.fgt_list, 0).id
    fgt2_pwd    = element(module.hub_2.fgt_list, 1).id
    fgt1_public = try(module.hub_2_nis.fgt_ni_list["az1.fgt1"]["public_eips"], "No Public IP")
  }
}
output "hub_2_vm" {
  value = module.hub_2_vm.vm
}

#-----------------------------------------------------------------------------------------------------
# VPN SDWAN
#-----------------------------------------------------------------------------------------------------
output "hubs" {
  value = local.o_hubs
}

#-----------------------------------------------------------------------------------------------------
# Servers NI
#-----------------------------------------------------------------------------------------------------
output "lab_server_ni" {
  value = aws_network_interface.lab_server_ni.id
}
output "fmail_ni" {
  value = aws_network_interface.fmail_ni.id
}

/*
#-------------------------------
# Debugging 
#-------------------------------
output "hub_1_ni_list" {
  value = module.hub_1_nis.ni_list
}
output "debugs" {
  value = { for k, v in module.hub_1_config : k => v.debugs }
}
output "eu_sdwan_ni_list" {
  value = { for k, v in module.eu_sdwan_nis : k => v.ni_list }
}

output "hub_1_public_eips" {
  value = local.hub_1_public_eips
}
*/