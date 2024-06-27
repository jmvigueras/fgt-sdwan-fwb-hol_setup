# Create NI for lab server
resource "aws_network_interface" "lab_server_ni" {
  subnet_id         = module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].subnet_ids["az1"]["vm"]
  security_groups   = [module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].sg_ids["allow_all"]]
  private_ips       = [local.lab_server_ip]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-lab-server"
  }
}
# Create NI for FMAIL
resource "aws_network_interface" "fmail_ni" {
  subnet_id         = module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].subnet_ids["az1"]["vm"]
  security_groups   = [module.hub_1_spoke_to_tgw["${local.hub_1_spoke_to_tgw_prefix}-0"].sg_ids["allow_all"]]
  private_ips       = [local.fmail_ip]
  source_dest_check = false

  tags = {
    Name = "${var.prefix}-fmail"
  }
}