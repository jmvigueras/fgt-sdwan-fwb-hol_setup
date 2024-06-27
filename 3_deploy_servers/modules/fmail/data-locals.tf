# Locals for generate resources
locals {
  ni_id      = var.ni_id
  public_ip = var.config_eip ? one(aws_eip.eip.*.public_ip) : ""
}

# Get current region
data "aws_region" "current" {}

# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fmail_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiMail-VMAW-64*${var.fmail_version}*PAYG*"]
  }
}
data "aws_ami_ids" "fmail_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiMail-VMAW-64*${var.fmail_version}*BYOL*"]
  }
}