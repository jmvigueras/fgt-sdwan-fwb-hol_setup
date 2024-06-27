output "fgt_ni_ids" {
  value = {
    public  = aws_network_interface.ni-public.id
    private = aws_network_interface.ni-private.id
  }
}

output "fgt_ni_ips" {
  value = {
    public  = local.fgt_ni_public_ip
    private = local.fgt_ni_private_ip
  }
}

output "subnet_az1_cidrs" {
  value = {
    public  = aws_subnet.subnet-az1-public.cidr_block
    private = aws_subnet.subnet-az1-private.cidr_block
    bastion = aws_subnet.subnet-az1-bastion.cidr_block
  }
}


output "subnet_az1_ids" {
  value = {
    public  = aws_subnet.subnet-az1-public.id
    private = aws_subnet.subnet-az1-private.id
    bastion = aws_subnet.subnet-az1-bastion.id
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "nsg_ids" {
  value = {
    private   = aws_security_group.nsg-vpc-private.id
    public    = aws_security_group.nsg-vpc-public.id
    bastion   = aws_security_group.nsg-vpc-bastion.id
    allow_all = aws_security_group.nsg-vpc-allow-all.id
  }
}