variable "rsa_public_key" {
  type    = string
  default = "null"
}
variable "api_key" {
  type    = string
  default = "null"
}
variable "key_pair_name" {
  type    = string
  default = "null"
}
variable "prefix" {
  type    = string
  default = "fwblab"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "spoke_prefix" {
  type    = string
  default = "r1"
}
variable "spoke_cidr_net" {
  type    = string
  default = "1"
}
variable "region" {
  type    = string
  default = "eu-west-1"
}
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1c"]
}
variable "admin_port" {
  type    = string
  default = "8443"
}
variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "instance_type" {
  type    = string
  default = "c6i.large"
}
variable "fgt_build" {
  type    = string
  default = "build2573"
}
variable "fgt_cluster_type" {
  type    = string
  default = "fgsp"
}
variable "license_type" {
  type    = string
  default = "payg"
}
variable "hub_1_vpc_cidr" {
  type    = string
  default = "10.1.0.0/24"
}
variable "hub_1_spoke_to_tgw_cidrs" {
  type    = list(string)
  default = ["10.1.100.0/24"]
}
variable "hub_2_vpc_cidr" {
  type    = string
  default = "10.2.0.0/24"
}
variable "vpn_hub_1" {
  type    = list(map(string))
  default = []
}
variable "vpn_hub_2" {
  type    = list(map(string))
  default = []
}
variable "app_external_port" {
  type    = string
  default = "80"
}
variable "app_mapped_port" {
  type    = string
  default = "80"
}
variable "hub_1_instance_type" {
  type    = string
  default = "c6in.large"
}
variable "hub_2_instance_type" {
  type    = string
  default = "c6in.large"
}
variable "route53_zone_name" {
  type    = string
  default = "fortidemoscloud.com"
}