# Generate aditional outputs
output "lab_server_details" {
  value = {
    lab_url        = "http://${local.server_fqdn}/${local.lab_token}"
    phpmyadmin_url = "http://${local.server_fqdn}/${local.random_url_db}"
  }
}

output "fortimail_details" {
  value = {
    mgmt_url  = "https://${local.fmail_fqdn}/admin"
    users_url = "https://${local.fmail_fqdn}"
    id        = module.fmail.id
  }
}

output "users_vm" {
  value = local.o_users_vm
}