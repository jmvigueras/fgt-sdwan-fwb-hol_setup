#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  lab_server_ip = cidrhost(module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].subnet_cidrs["az1"]["vm"], 10)
  fmail_ip      = cidrhost(module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].subnet_cidrs["az1"]["vm"], 11)

  #-----------------------------------------------------------------------------------------------------
  # HUB 1
  #-----------------------------------------------------------------------------------------------------
  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  hub_1_fgt_subnet_tags = {
    "port1.public"  = "public"
    "port2.private" = "private"
    "port3.mgmt"    = ""
  }

  # General variables 
  hub_1_number_peer_az = 1
  hub_1_cluster_type   = "fgsp"
  hub_1_vpc_cidr       = var.hub_1_vpc_cidr

  # VPN HUB variables
  hub_1_id       = "HUB1"
  hub_1_bgp_asn  = lookup(var.vpn_hub_1[0], "bgp_asn_hub", "65001")
  hub_1_cidr     = "10.0.0.0/8"
  hub_1_vpn_cidr = "172.16.100.0/24" // VPN DialUp spokes cidr
  hub_1_vpn_ddns = var.hub_1_dns_record
  hub_1_vpn_fqdn = "${local.hub_1_vpn_ddns}.${var.route53_zone_name}"

  # Config VPN DialUps FGT HUBs
  hub_1 = [for hub in var.vpn_hub_1 :
    {
      id                = lookup(hub, "id", "HUB1")
      bgp_asn_hub       = local.hub_1_bgp_asn
      bgp_asn_spoke     = lookup(hub, "bgp_asn_spoke", local.hub_2_bgp_asn)
      vpn_cidr          = hub["vpn_cidr"]
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = lookup(hub, "ike_version", "2")
      network_id        = lookup(hub, "network_id", "1")
      dpd_retryinterval = lookup(hub, "network_id", "5")
      mode_cfg          = true
      vpn_port          = lookup(hub, "vpn_port", "public")
      local_gw          = lookup(hub, "local_gw", "")
    }
  ]

  # EU HUB TGW
  tgw_cidr    = "172.16.10.0/24"
  tgw_bgp_asn = "65011"

  # EU VPC SPOKE TO TGW
  hub_1_spoke_to_tgw_prefix = "hub-1-spoke-to-tgw"
  hub_1_spoke_to_tgw = { for i, k in var.hub_1_spoke_to_tgw_cidrs :
    "${local.hub_1_spoke_to_tgw_prefix}-${i}" => k
  }

  #-----------------------------------------------------------------------------------------------------
  # HUB 2
  #-----------------------------------------------------------------------------------------------------
  # fgt_subnet_tags -> add tags to FGT subnets (port1, port2, public, private ...)
  hub_2_fgt_subnet_tags = {
    "port1.public"  = "public"
    "port2.private" = "private"
    "port3.mgmt"    = "mgmt"
  }

  # General variables 
  hub_2_number_peer_az = 1
  hub_2_cluster_type   = "fgcp"
  hub_2_vpc_cidr       = var.hub_2_vpc_cidr

  # VPN HUB variables
  hub_2_bgp_asn  = lookup(var.vpn_hub_2[0], "bgp_asn_hub", "65000")
  hub_2_cidr     = "10.0.0.0/8"
  hub_2_vpn_cidr = "172.20.100.0/24" // VPN DialUp spokes cidr

  hub_2_vpn_ddns = var.hub_2_dns_record
  hub_2_vpn_fqdn = "${local.hub_2_vpn_ddns}.${var.route53_zone_name}"

  hub_2 = [for hub in var.vpn_hub_2 :
    {
      id                = lookup(hub, "id", "HUB2")
      bgp_asn_hub       = local.hub_2_bgp_asn
      bgp_asn_spoke     = lookup(hub, "bgp_asn_spoke", local.hub_2_bgp_asn)
      vpn_cidr          = hub["vpn_cidr"]
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = lookup(hub, "ike_version", "2")
      network_id        = lookup(hub, "network_id", "1")
      dpd_retryinterval = lookup(hub, "network_id", "5")
      mode_cfg          = true
      vpn_port          = lookup(hub, "vpn_port", "public")
      local_gw          = lookup(hub, "local_gw", "")
    }
  ]
  #-----------------------------------------------------------------------------------------------------
  # Overlays VXLAN
  #-----------------------------------------------------------------------------------------------------
  # VXLAN HUB to HUB variables
  hub_1_vxlan_cidr = "172.16.11.0/24" // VXLAN cluster members cidr
  hub_1_vxlan_vni  = "1101"           // VXLAN cluster members vni ID 

  hub_1_to_hub_2_vxlan_cidr = "172.16.12.0/24" // VXLAN to OP cidr
  hub_1_to_hub_2_vxlan_vni  = "1102"           // VXLAN to OP VNI ID
}
