#------------------------------------------------------------------------------
# Create FGT cluster EU
# - VPC
# - FGT NI and SG
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "hub_2_vpc" {
  source = "./sub_modules/vpc"

  prefix     = "${var.prefix}-hub-2"
  admin_cidr = var.admin_cidr
  region     = var.region
  azs        = var.azs

  cidr = local.hub_2_vpc_cidr

  public_subnet_names  = local.hub_2_fgt_vpc_public_subnet_names
  private_subnet_names = local.hub_2_fgt_vpc_private_subnet_names
}
# Create FGT NIs
module "hub_2_nis" {
  source = "./sub_modules/fgt_ni_sg"

  prefix             = "${var.prefix}-hub-2"
  azs                = var.azs
  vpc_id             = module.hub_2_vpc.vpc_id
  subnet_list        = module.hub_2_vpc.subnet_list
  fgt_subnet_tags    = local.hub_2_fgt_subnet_tags
  fgt_number_peer_az = local.hub_2_number_peer_az
  cluster_type       = local.hub_2_cluster_type
}
module "hub_2_config" {
  for_each = { for k, v in module.hub_2_nis.fgt_ports_config : k => v }
  source   = "./sub_modules/fgt_config"

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = var.rsa_public_key
  api_key        = var.api_key

  ports_config = each.value

  config_fgcp       = local.hub_2_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.hub_2_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.hub_2_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.hub_2_nis.fgt_ports_config

  config_hub = true
  hub        = local.hub_2

  config_vxlan = true
  vxlan_peers  = local.hub_2_vxlan_peers[each.key]

  static_route_cidrs = [local.hub_1_vpc_cidr, local.hub_2_vpc_cidr] // necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "hub_2" {
  source = "./sub_modules/fgt"

  prefix        = "${var.prefix}-hub-2"
  region        = var.region
  instance_type = var.instance_type
  keypair       = var.key_pair_name

  license_type = var.license_type
  fgt_build    = var.fgt_build

  fgt_ni_list = module.hub_2_nis.fgt_ni_list
  fgt_config  = { for k, v in module.hub_2_config : k => v.fgt_config }
}
# Create TGW attachment
module "hub_2_to_tgw_attachment" {
  source = "./sub_modules/tgw_attachment"

  prefix = "${var.prefix}-hub-2"

  vpc_id             = module.hub_2_vpc.vpc_id
  tgw_id             = module.tgw.tgw_id
  tgw_subnet_ids     = compact([for i, az in var.azs : lookup(module.hub_2_vpc.subnet_ids["az${i + 1}"], "tgw", "")])
  rt_association_id  = module.tgw.rt_pre_inspection_id
  rt_propagation_ids = [module.tgw.rt_post_inspection_id]

  appliance_mode_support = "disable"
}
# Update private RT route RFC1918 cidrs to FGT NI and TGW
module "hub_2_vpc_routes" {
  source = "./sub_modules/vpc_routes"

  ni_id     = module.hub_2_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.hub_2_ni_rt_ids

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.hub_2_tgw_rt_ids
}
# Crate test VM in bastion subnet
module "hub_2_vm" {
  source = "./sub_modules/vm"

  prefix          = "${var.prefix}-hub-2"
  keypair         = var.key_pair_name
  subnet_id       = module.hub_2_vpc.subnet_ids["az1"]["bastion"]
  subnet_cidr     = module.hub_2_vpc.subnet_cidrs["az1"]["bastion"]
  security_groups = [module.hub_2_vpc.sg_ids["default"]]
}