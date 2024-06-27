# Create users VM in Region 1
module "r1_users_vm" {
  source = "./modules/user_vm"

  region        = local.r1_region
  key_pair_name = local.keypair_names["r1"]
  prefix        = local.prefix
  instance_type = local.k8s_instance_type

  user_vm_ni_ids      = local.user_vm_ni_ids["r1"]
  user_fgt_eip_public = local.user_fgt_eip_public["r1"]

  app1_mapped_port = local.app1_mapped_port
  app2_mapped_port = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}
# Create users VM in Region 2
module "r2_users_vm" {
  source = "./modules/user_vm"

  region        = local.r2_region
  key_pair_name = local.keypair_names["r2"]
  prefix        = local.prefix
  instance_type = local.k8s_instance_type

  user_vm_ni_ids      = local.user_vm_ni_ids["r2"]
  user_fgt_eip_public = local.user_fgt_eip_public["r2"]

  app1_mapped_port = local.app1_mapped_port
  app2_mapped_port = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}
# Create users VM in Region 3
module "r3_users_vm" {
  source = "./modules/user_vm"

  region        = local.r3_region
  key_pair_name = local.keypair_names["r3"]
  prefix        = local.prefix
  instance_type = local.k8s_instance_type

  user_vm_ni_ids      = local.user_vm_ni_ids["r3"]
  user_fgt_eip_public = local.user_fgt_eip_public["r3"]

  app1_mapped_port = local.app1_mapped_port
  app2_mapped_port = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}

