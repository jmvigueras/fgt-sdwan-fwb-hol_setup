# Output
output "user_vms" {
  value = { for k, v in module.user_vm : k => v.vm }
}