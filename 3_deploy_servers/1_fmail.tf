# Create fmail VM
module "fmail" {
  source = "./modules/fmail"

  prefix        = local.prefix
  region        = local.hub_region
  keypair       = local.keypair_names["hub"]
  license_type  = local.fmail_license_type
  fmail_version = local.fmail_version

  ni_id      = local.hub_fmail_ni
  config_eip = false

  access_key = var.access_key
  secret_key = var.secret_key
}