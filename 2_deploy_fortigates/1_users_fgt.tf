# Crate Users FGT in Region 1
module "r1_users_fgt" {
  source = "./modules/user_fgt"

  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  key_pair_name  = aws_key_pair.r1_keypair.key_name
  instance_type  = local.fgt_instance_type
  fgt_build      = local.fgt_build

  region = local.r1_region

  prefix         = local.prefix
  spoke_prefix   = "r1"
  spoke_cidr_net = "10" // "10.${spoke_cidr_net}.${user_number}.0/24"

  number_users = local.number_users
  vpn_hubs     = local.vpn_hubs

  app1_external_port = local.app1_external_port
  app2_external_port = local.app2_external_port
  app1_mapped_port   = local.app1_mapped_port
  app2_mapped_port   = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}
# Crate Users FGT in Region 2
module "r2_users_fgt" {
  source = "./modules/user_fgt"

  region = local.r2_region

  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  key_pair_name  = aws_key_pair.r2_keypair.key_name
  instance_type  = local.fgt_instance_type
  fgt_build      = local.fgt_build

  prefix         = local.prefix
  spoke_prefix   = "r2"
  spoke_cidr_net = "20" // "10.${spoke_cidr_net}.${user_number}.0/24"

  number_users = local.number_users
  vpn_hubs     = local.vpn_hubs

  app1_external_port = local.app1_external_port
  app2_external_port = local.app2_external_port
  app1_mapped_port   = local.app1_mapped_port
  app2_mapped_port   = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}
# Crate Users FGT in Region 3
module "r3_users_fgt" {
  source = "./modules/user_fgt"

  region = local.r3_region

  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)
  api_key        = trimspace(random_string.api_key.result)
  key_pair_name  = aws_key_pair.r3_keypair.key_name
  instance_type  = local.fgt_instance_type
  fgt_build      = local.fgt_build

  prefix         = local.prefix
  spoke_prefix   = "r3"
  spoke_cidr_net = "30" // "10.${spoke_cidr_net}.${user_number}.0/24"

  number_users = local.number_users
  vpn_hubs     = local.vpn_hubs

  app1_external_port = local.app1_external_port
  app2_external_port = local.app2_external_port
  app1_mapped_port   = local.app1_mapped_port
  app2_mapped_port   = local.app2_mapped_port

  access_key = var.access_key
  secret_key = var.secret_key
}







