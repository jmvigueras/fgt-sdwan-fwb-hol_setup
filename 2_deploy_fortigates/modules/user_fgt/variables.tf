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
variable "spoke_prefix" {
  type    = string
  default = "r1"
}
variable "spoke_cidr_net" {
  type    = string
  default = "1"
}
variable "region" {
  type    = map(string)
  default = {     
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
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
variable "license_type" {
  type    = string
  default = "payg"
}
variable "hub_vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "vpn_hubs" {
  type    = list(map(string))
  default = null
}
variable "bgp_asn" {
  type    = string
  default = "65000"
}

variable "number_users" {
  type    = number
  default = 1
}

variable "app1_external_port" {
  type    = string
  default = "31000"
}
variable "app2_external_port" {
  type    = string
  default = "31001"
} 
variable "app1_mapped_port" {
  type    = string
  default = "31000"
}
variable "app2_mapped_port" {
  type    = string
  default = "31001"
} 