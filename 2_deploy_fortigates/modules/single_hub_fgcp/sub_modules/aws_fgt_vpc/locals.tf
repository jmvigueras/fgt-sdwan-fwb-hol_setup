locals {
  # ----------------------------------------------------------------------------------
  # Subnet cidrs (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  subnet_az1_public_cidr  = cidrsubnet(var.vpc_cidr, 2, 0)
  subnet_az1_private_cidr = cidrsubnet(var.vpc_cidr, 2, 1)
  subnet_az1_bastion_cidr = cidrsubnet(var.vpc_cidr, 2, 2)

  # ----------------------------------------------------------------------------------
  # FGT IP (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt_ni_public_ip  = cidrhost(local.subnet_az1_public_cidr, 10)
  fgt_ni_private_ip = cidrhost(local.subnet_az1_private_cidr, 10)

  # ----------------------------------------------------------------------------------
  # FGT IPs (NOT UPDATE)
  # ----------------------------------------------------------------------------------
  fgt_ni_public_ips  = [local.fgt_ni_public_ip]
  fgt_ni_private_ips = [local.fgt_ni_private_ip]
}