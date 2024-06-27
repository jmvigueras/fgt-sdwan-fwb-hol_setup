#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  fgt_ports = {
    public  = "port1"
    private = "port2"
  }

  lab_server_ip = cidrhost(module.hub_vpc.subnet_az1_cidrs["bastion"], 10)
  fmail_ip      = cidrhost(module.hub_vpc.subnet_az1_cidrs["bastion"], 11)
  #-----------------------------------------------------------------------------------------------------
  # VPN HUBs variables
  #-----------------------------------------------------------------------------------------------------
  # Config VPN DialUps FGT HUB
  hub = [ for hub in var.hub :
    {
      id                = lookup(hub, "id", "HUB")
      bgp_asn_hub       = lookup(hub, "bgp_asn_hub", "65000")
      bgp_asn_spoke     = lookup(hub, "bgp_asn_spoke", "65000")
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

}