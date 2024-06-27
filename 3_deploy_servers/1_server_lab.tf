#--------------------------------------------------------------------------------------------
# Create LAB Server
#--------------------------------------------------------------------------------------------
# Create master node LAB server
module "lab_server" {
  source = "./modules/hub_vm"

  region        = local.r1_region
  prefix        = "${local.prefix}-lab-server"
  keypair       = local.keypair_names["r1"]
  instance_type = local.lab_srv_type
  linux_os      = "amazon"
  user_data     = data.template_file.srv_user_data.rendered

  ni_id = local.hub_bastion_ni

  access_key = var.access_key
  secret_key = var.secret_key
}
# Create user-data for server
data "template_file" "srv_user_data" {
  template = file("./templates/server_user-data.tpl")
  vars = {
    git_uri          = local.git_uri
    git_uri_app_path = local.git_uri_app_path
    docker_file      = data.template_file.srv_user_data_dockerfile.rendered
    nginx_config     = data.template_file.srv_user_data_nginx_config.rendered
    nginx_html       = data.template_file.srv_user_data_nginx_html.rendered

    db_host  = local.db["db_host"]
    db_user  = local.db["db_user"]
    db_pass  = local.db["db_pass"]
    db_name  = local.db["db_name"]
    db_table = local.db["db_table"]
    db_port  = local.db["db_port"]
  }
}
// Create dockerfile
data "template_file" "srv_user_data_dockerfile" {
  template = file("./templates/docker-compose.yaml")
  vars = {
    lab_fqdn      = local.lab_fqdn
    random_url_db = local.random_url_db
    db_host       = local.db["db_host"]
    db_user       = local.db["db_user"]
    db_pass       = local.db["db_pass"]
    db_name       = local.db["db_name"]
    db_table      = local.db["db_table"]
    db_port       = local.db["db_port"]
  }
}
// Create nginx config
data "template_file" "srv_user_data_nginx_config" {
  template = file("./templates/nginx_config.tpl")
  vars = {
    lab_token      = local.lab_token
    random_url_db  = local.random_url_db
  }
}
// Create nginx html
data "template_file" "srv_user_data_nginx_html" {
  template = file("./templates/nginx_html.tpl")
  vars = {
    lab_fqdn = local.lab_fqdn
  }
}