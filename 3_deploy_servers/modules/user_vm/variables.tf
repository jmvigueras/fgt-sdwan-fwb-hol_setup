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
  default = null
} 
variable "user_vm_ni_ids" {
  type    = map(string)
  default = null
} 
variable "user_fgt_eip_public" {
  type    = map(string)
  default = null
} 
variable "app1_mapped_port" {
  type    = string
  default = "31000"
}
variable "app2_mapped_port" {
  type    = string
  default = "31001"
} 
variable "instance_type" {
  type    = string
  default = "t3.xlarge"
} 