output "details" {
  description = "FortiMail details"
  value = {
    id         = aws_instance.fmail.id
    username   = var.admin_username
    public_ip  = local.public_ip
  }
}

output "id" {
  description = "FortiMail instance ID"
  value       = aws_instance.fmail.id
}

output "public_ip" {
  description = "FortiMail public IP"
  value       = local.public_ip
}