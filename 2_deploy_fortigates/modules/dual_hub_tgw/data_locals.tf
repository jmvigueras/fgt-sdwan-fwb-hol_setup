locals {
  ## Generate locals needed at modules ##
  #-----------------------------------------------------------------------------------------------------
  # HUB 1
  #-----------------------------------------------------------------------------------------------------
  # List of public and private subnet to create FGT VPC
  hub_1_fgt_vpc_public_subnet_names  = [local.hub_1_fgt_subnet_tags["port1.public"], local.hub_1_fgt_subnet_tags["port3.mgmt"]]
  hub_1_fgt_vpc_private_subnet_names = [local.hub_1_fgt_subnet_tags["port2.private"], "tgw"]

  # List of subnet names to add a route to FGT NI
  hub_1_ni_rt_subnet_names = ["tgw"]
  # List of subnet names to add a route to a TGW
  hub_1_tgw_rt_subnet_names = [local.hub_1_fgt_subnet_tags["port2.private"]]

  # Create map of RT IDs where add routes pointing to a FGT NI
  hub_1_ni_rt_ids = {
    for pair in setproduct(local.hub_1_ni_rt_subnet_names, [for i, az in var.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_1_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  hub_1_tgw_rt_ids = {
    for pair in setproduct(local.hub_1_tgw_rt_subnet_names, [for i, az in var.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_1_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Map of public IPs of EU HUB
  hub_1_public_eips = module.hub_1_nis.fgt_eips_map

  # EU HUB TGW variables (used for module tgw_connect)
  hub_1_tgw_peers = [
    for i in range(0, length(keys(module.hub_1_nis.fgt_ips_map))) :
    { "inside_cidr" = "169.254.${i + 101}.0/29",
      "tgw_ip"      = cidrhost(local.tgw_cidr, 10 + i),
      "id"          = keys(module.hub_1_nis.fgt_ips_map)[i],
      "fgt_ip"      = values(module.hub_1_nis.fgt_ips_map)[i]["port2.private"]
      "fgt_bgp_asn" = local.hub_1_bgp_asn
    }
  ]
  # VXLAN list of peers peer HUB cluster with values need in config module
  hub_1_cluster_vxlan_peers_list = [
    for i in range(0, length(keys(module.hub_1_nis.fgt_ips_map))) :
    { external_ip   = join(",", [for ii, ip in values(module.hub_1_nis.fgt_ips_map) : ip["port2.private"] if ii != i])
      remote_ip     = join(",", [for ii in range(0, length(module.hub_1_nis.fgt_ips_map)) : cidrhost(local.hub_1_vxlan_cidr, ii + 1) if ii != i])
      local_ip      = cidrhost(local.hub_1_vxlan_cidr, i + 1)
      vni           = local.hub_1_vxlan_vni
      vxlan_port    = "private"
      bgp_asn       = local.hub_1_bgp_asn
      route_map_out = "rm_out_hub_to_hub_0" //created by default add community 65001:10
    }
  ]
  # VXLAN list of peers peer HUB to ON-PREMISES HUB with values need in config module
  hub_1_to_hub_2_vxlan_peers_list = [
    for i in range(0, length(keys(module.hub_1_nis.fgt_ips_map))) :
    { external_ip   = join(",", [for ii, ip in values(module.hub_2_nis.fgt_ips_map) : ip["port2.private"]])
      remote_ip     = join(",", [for ii in range(0, length(module.hub_2_nis.fgt_ips_map)) : cidrhost(local.hub_1_to_hub_2_vxlan_cidr, ii + 1 + length(module.hub_1_nis.fgt_ips_map))])
      local_ip      = cidrhost(local.hub_1_to_hub_2_vxlan_cidr, i + 1)
      vni           = local.hub_1_to_hub_2_vxlan_vni
      vxlan_port    = "private"
      bgp_asn       = local.hub_2_bgp_asn
      route_map_out = "rm_out_hub_to_hub_0" //created by default add community 65001:10
    }
  ]
  # Generate a map for each deployed FGT HUB with vxlan peers values
  hub_1_vxlan_peers = zipmap(
    keys(module.hub_1_nis.fgt_ips_map), [
      for i in range(0, length(keys(module.hub_1_nis.fgt_ips_map))) : [
        local.hub_1_cluster_vxlan_peers_list[i],
        local.hub_1_to_hub_2_vxlan_peers_list[i],
      ]
    ]
  )

  #-----------------------------------------------------------------------------------------------------
  # HUB SDWAN SPOKES
  #-----------------------------------------------------------------------------------------------------
  hub_1_private_ip = ""
  hub_2_private_ip = ""

  # SDWAN spoke VPN hubs
  o_hubs = concat(local.hubs_1, local.hubs_2)

  # Define SDWAN HUB 1 VPN
  hubs_1 = [for hub in local.hub_1 :
    {
      id                = hub["id"]
      bgp_asn           = hub["bgp_asn_hub"]
      external_fqdn     = hub["vpn_port"] == "public" ? local.hub_1_vpn_fqdn : local.hub_1_private_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 0), 3)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = lookup(hub, "ike_version", "2")
      network_id        = lookup(hub, "network_id", "1")
      dpd_retryinterval = lookup(hub, "network_id", "5")
      sdwan_port        = lookup(hub, "vpn_port", "public")
    }
  ]

  # Define SDWAN HUB EMEA ON-PREM
  hubs_2 = [for hub in local.hub_2 :
    {
      id      = hub["id"]
      bgp_asn = hub["bgp_asn_hub"]
      // external_ip       = hub["vpn_port"] == "public" ? local.hub_1_public_ip : local.hub_1_private_ip
      external_fqdn     = hub["vpn_port"] == "public" ? local.hub_2_vpn_fqdn : local.hub_2_private_ip
      hub_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      site_ip           = hub["mode_cfg"] ? "" : cidrhost(cidrsubnet(hub["vpn_cidr"], 0), 3)
      hck_ip            = cidrhost(cidrsubnet(hub["vpn_cidr"], 0, 0), 1)
      vpn_psk           = hub["vpn_psk"]
      cidr              = hub["cidr"]
      ike_version       = lookup(hub, "ike_version", "2")
      network_id        = lookup(hub, "network_id", "1")
      dpd_retryinterval = lookup(hub, "network_id", "5")
      sdwan_port        = lookup(hub, "vpn_port", "public")
    }
  ]

  #-----------------------------------------------------------------------------------------------------
  # HUB 2
  #-----------------------------------------------------------------------------------------------------
  # List of public and private subnet to create FGT VPC
  hub_2_fgt_vpc_public_subnet_names  = [local.hub_2_fgt_subnet_tags["port1.public"], local.hub_2_fgt_subnet_tags["port3.mgmt"]]
  hub_2_fgt_vpc_private_subnet_names = [local.hub_2_fgt_subnet_tags["port2.private"], "tgw", "bastion"]

  # List of subnet names to add a route to FGT NI
  hub_2_ni_rt_subnet_names = ["tgw", "bastion"]
  # List of subnet names to add a route to a TGW
  hub_2_tgw_rt_subnet_names = [local.hub_1_fgt_subnet_tags["port2.private"]]

  # Create map of RT IDs where add routes pointing to a FGT NI
  hub_2_ni_rt_ids = {
    for pair in setproduct(local.hub_2_ni_rt_subnet_names, [for i, az in var.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_2_vpc.rt_ids[pair[1]][pair[0]]
  }
  # Create map of RT IDs where add routes pointing to a TGW ID
  hub_2_tgw_rt_ids = {
    for pair in setproduct(local.hub_2_tgw_rt_subnet_names, [for i, az in var.azs : "az${i + 1}"]) :
    "${pair[0]}-${pair[1]}" => module.hub_2_vpc.rt_ids[pair[1]][pair[0]]
  }

  # Map of public IPs of EU HUB
  hub_2_public_eips = module.hub_2_nis.fgt_eips_map

  # VXLAN list of peers peer OP cluster with values need in config module
  hub_2_to_hub_1_vxlan_peers_list = [
    for i in range(0, length(keys(module.hub_2_nis.fgt_ips_map))) :
    { external_ip   = join(",", [for ii, ip in values(module.hub_1_nis.fgt_ips_map) : ip["port2.private"]])
      remote_ip     = join(",", [for ii in range(0, length(module.hub_1_nis.fgt_ips_map)) : cidrhost(local.hub_1_to_hub_2_vxlan_cidr, ii + 1)])
      local_ip      = cidrhost(local.hub_1_to_hub_2_vxlan_cidr, i + 1 + length(module.hub_1_nis.fgt_ips_map))
      vni           = local.hub_1_to_hub_2_vxlan_vni
      vxlan_port    = "private"
      bgp_asn       = local.hub_1_bgp_asn
      route_map_out = "rm_out_hub_to_hub_0" //created by default add community 65001:10
    }
  ]
  # Generate a map for each deployed FGT HUB with vxlan peers values
  hub_2_vxlan_peers = zipmap(
    keys(module.hub_2_nis.fgt_ips_map), [
      for i in range(0, length(keys(module.hub_2_nis.fgt_ips_map))) : [
        local.hub_2_to_hub_1_vxlan_peers_list[i]
      ]
    ]
  )

  fgt_ports = {
    public  = "port1"
    private = "port2"
    mgmt    = "port3"
  }

  #-----------------------------------------------------------------------------------------------------
  # HUB 1 - Config
  #-----------------------------------------------------------------------------------------------------
  hub_1_extra_data = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => join("\n",
      [local.hub_extra_config_lab_server[k]],
      [local.hub_extra_config_lab_server_ssh[k]],
      [local.hub_extra_config_lab_fmail_ssh[k]],
      [local.hub_extra_config_lab_fmail_https[k]],
      [local.hub_extra_config_lab_fmail_smtp_1[k]],
      [local.hub_extra_config_lab_fmail_smtp_2[k]],
      [local.hub_extra_config_fw_policies[k]]
    )
  }
  hub_extra_config_lab_server = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.lab_server_ip
        external_port = var.app_external_port
        mapped_port   = var.app_mapped_port
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = var.app_external_port
      }
    )
  }
  hub_extra_config_lab_server_ssh = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.lab_server_ip
        external_port = "2222"
        mapped_port   = "22"
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = "2222"
      }
    )
  }
  hub_extra_config_lab_fmail_ssh = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.fmail_ip
        external_port = "2223"
        mapped_port   = "22"
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = "2223"
      }
    )
  }
  hub_extra_config_lab_fmail_https = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.fmail_ip
        external_port = "443"
        mapped_port   = "443"
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = "443"
      }
    )
  }
  hub_extra_config_lab_fmail_smtp_1 = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.fmail_ip
        external_port = "25"
        mapped_port   = "25"
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = "25"
      }
    )
  }
  hub_extra_config_lab_fmail_smtp_2 = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_vip.conf",
      { external_ip   = element([for port in v : port["ip"] if port["tag"] == "public"], 0)
        mapped_ip     = local.fmail_ip
        external_port = "587"
        mapped_port   = "587"
        public_port   = element([for port in v : port["port"] if port["tag"] == "public"], 0)
        private_port  = element([for port in v : port["port"] if port["tag"] == "private"], 0)
        suffix        = "587"
      }
    )
  }
  hub_extra_config_fw_policies = { for k, v in module.hub_1_nis.fgt_ports_config :
    k => templatefile(
      "${path.module}/templates/fgt_policy.conf",
      {
        public_port = element([for port in v : port["port"] if port["tag"] == "public"], 0)
      }
    )
  }
}
