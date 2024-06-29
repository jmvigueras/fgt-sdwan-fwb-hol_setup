# Output
output "user_vm" {
  value = { for k, v in module.user_vm : k => v.vm }
}