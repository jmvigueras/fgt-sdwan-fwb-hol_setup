#------------------------------------------------------------------------------
# Create FGT cluster EU
# - VPC
# - FGT NI and SG
# - FGT instance
#------------------------------------------------------------------------------
# Create VPC for hub EU
module "hub_1_vpc" {
  source = "./sub_modules/vpc"

  prefix     = "${var.prefix}-hub-1"
  admin_cidr = var.admin_cidr
  region     = var.region
  azs        = var.azs

  cidr = var.hub_1_vpc_cidr

  public_subnet_names  = local.hub_1_fgt_vpc_public_subnet_names
  private_subnet_names = local.hub_1_fgt_vpc_private_subnet_names
}
# Create FGT NIs
module "hub_1_nis" {
  source = "./sub_modules/fgt_ni_sg"

  prefix             = "${var.prefix}-hub-1"
  azs                = var.azs
  vpc_id             = module.hub_1_vpc.vpc_id
  subnet_list        = module.hub_1_vpc.subnet_list
  fgt_subnet_tags    = local.hub_1_fgt_subnet_tags
  fgt_number_peer_az = local.hub_1_number_peer_az
  cluster_type       = local.hub_1_cluster_type
}
# Create FGTs Config
module "hub_1_config" {
  source = "./sub_modules/fgt_config"

  for_each = { for k, v in module.hub_1_nis.fgt_ports_config : k => v }

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = var.rsa_public_key
  api_key        = var.api_key

  ports_config = each.value

  config_fgcp       = local.hub_1_cluster_type == "fgcp" ? true : false
  config_fgsp       = local.hub_1_cluster_type == "fgsp" ? true : false
  config_auto_scale = local.hub_1_cluster_type == "fgsp" ? true : false

  fgt_id     = each.key
  ha_members = module.hub_1_nis.fgt_ports_config

  config_hub = true
  hub        = local.hub_1

  config_tgw_gre = true
  tgw_gre_peer = {
    tgw_ip            = one([for i, v in local.hub_1_tgw_peers : v["tgw_ip"] if v["id"] == each.key])
    inside_cidr       = one([for i, v in local.hub_1_tgw_peers : v["inside_cidr"] if v["id"] == each.key])
    twg_bgp_asn       = local.tgw_bgp_asn
    route_map_out     = "rm_out_hub_to_external_0" //created by default prepend routes with community 65001:10
    route_map_in      = ""
    gre_name          = "gre-to-tgw"
    default_originate = true
  }

  config_vxlan = true
  vxlan_peers  = local.hub_1_vxlan_peers[each.key]

  config_fw_policy = false
  config_extra     = local.hub_1_extra_data[each.key]

  static_route_cidrs = [local.hub_1_vpc_cidr, local.tgw_cidr, local.hub_2_vpc_cidr] //necessary routes to stablish BGP peerings and bastion connection
}
# Create FGT for hub EU
module "hub_1" {
  source = "./sub_modules/fgt"

  prefix        = "${var.prefix}-hub-1"
  region        = var.region
  instance_type = var.instance_type
  keypair       = var.key_pair_name

  license_type = var.license_type
  fgt_build    = var.fgt_build

  fgt_ni_list = module.hub_1_nis.fgt_ni_list
  fgt_config  = { for k, v in module.hub_1_config : k => v.fgt_config }
}
# Create TGW
module "tgw" {
  source = "./sub_modules/tgw"

  prefix = "${var.prefix}-hub-1"

  tgw_cidr    = local.tgw_cidr
  tgw_bgp_asn = local.tgw_bgp_asn
}
# Create TGW attachment
module "hub_1_vpc_tgw_attachment" {
  source = "./sub_modules/tgw_attachment"

  prefix = "${var.prefix}-hub-1"

  vpc_id         = module.hub_1_vpc.vpc_id
  tgw_id         = module.tgw.tgw_id
  tgw_subnet_ids = compact([for i, az in var.azs : lookup(module.hub_1_vpc.subnet_ids["az${i + 1}"], "tgw", "")])

  default_rt_association = true
  default_rt_propagation = true
  appliance_mode_support = "enable"
}
# Create TGW attachment connect
module "hub_1_vpc_tgw_connect" {
  source = "./sub_modules/tgw_connect"

  prefix = "${var.prefix}-hub-1"

  vpc_attachment_id = module.hub_1_vpc_tgw_attachment.id
  tgw_id            = module.tgw.tgw_id
  peers             = local.hub_1_tgw_peers

  rt_association_id  = module.tgw.rt_post_inspection_id
  rt_propagation_ids = [module.tgw.rt_pre_inspection_id]

  tags = var.tags
}
# Update private RT route RFC1918 cidrs to FGT NI and TGW
module "hub_1_vpc_routes" {
  source = "./sub_modules/vpc_routes"

  tgw_id     = module.tgw.tgw_id
  tgw_rt_ids = local.hub_1_tgw_rt_ids

  ni_id     = module.hub_1_nis.fgt_ids_map["az1.fgt1"]["port2.private"]
  ni_rt_ids = local.hub_1_ni_rt_ids
}
#------------------------------------------------------------------------------
# VPC Spoke to TGW
#------------------------------------------------------------------------------
# Create VPC spoke to TGW
module "hub_1_spoke_to_tgw" {
  source = "./sub_modules/vpc"

  for_each = local.hub_1_spoke_to_tgw

  prefix = "${var.prefix}-hub-1-spoke"
  azs    = var.azs

  cidr = each.value

  public_subnet_names  = []
  private_subnet_names = ["tgw", "vm"]
}
# Create TGW attachment
module "hub_1_spoke_to_tgw_attachment" {
  source = "./sub_modules/tgw_attachment"

  for_each = local.hub_1_spoke_to_tgw

  prefix = "${var.prefix}-${each.key}"

  vpc_id             = module.hub_1_spoke_to_tgw[each.key].vpc_id
  tgw_id             = module.tgw.tgw_id
  tgw_subnet_ids     = compact([for i, az in var.azs : lookup(module.hub_1_spoke_to_tgw[each.key].subnet_ids["az${i + 1}"], "tgw", "")])
  rt_association_id  = module.tgw.rt_pre_inspection_id
  rt_propagation_ids = [module.tgw.rt_post_inspection_id]

  appliance_mode_support = "disable"
}
# Update private RT route RFC1918 cidrs to FGT NI and TGW
module "hub_1_spoke_to_tgw_routes" {
  source = "./sub_modules/vpc_routes"

  for_each = local.hub_1_spoke_to_tgw

  tgw_id = module.tgw.tgw_id
  tgw_rt_ids = { for pair in setproduct(["vm"], [for i, az in var.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_1_spoke_to_tgw[each.key].rt_ids[pair[1]][pair[0]]
  }
}
# Crate test VM in bastion subnet
module "hub_1_spoke_to_tgw_vm" {
  source = "./sub_modules/vm"

  for_each = { for k, v in local.hub_1_spoke_to_tgw : k => v if k != "${local.hub_1_spoke_to_tgw_prefix}-0" } // create VM in all VPC TGW attached except 0

  prefix          = "${var.prefix}-${each.key}"
  keypair         = var.key_pair_name
  subnet_id       = module.hub_1_spoke_to_tgw[each.key].subnet_ids["az1"]["vm"]
  subnet_cidr     = module.hub_1_spoke_to_tgw[each.key].subnet_cidrs["az1"]["vm"]
  security_groups = [module.hub_1_spoke_to_tgw[each.key].sg_ids["default"]]
}
