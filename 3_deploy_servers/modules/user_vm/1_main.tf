#------------------------------------------------------------------------------
# Create USERS instances
#------------------------------------------------------------------------------
# Create user VM
module "user_vm" {
  source = "./sub_modules/aws_new_vm_ni"

  for_each = var.user_vm_ni_ids

  prefix  = "${var.prefix}-${each.key}"
  keypair = var.key_pair_name

  instance_type = var.instance_type
  user_data     = data.template_file.user_vm_userdata[each.key].rendered

  ni_id = each.value
}
# Create data template for master node
data "template_file" "user_vm_userdata" {
  for_each = var.user_vm_ni_ids

  template = file("${path.module}/templates/k8s.sh")
  vars = {
    k8s_version    = "1.28"
    linux_user     = "ubuntu"
    k8s_deployment = data.template_file.k8s_app_deployment[each.key].rendered
  }
}
# Create k8s manifest from template to deploy voting app
data "template_file" "k8s_app_deployment" {
  for_each = var.user_vm_ni_ids

  template = file("${path.module}/templates/k8s-dvwa-swagger.yaml")
  vars = {
    dvwa_nodeport    = var.app1_mapped_port
    swagger_nodeport = var.app2_mapped_port
    swagger_host     = var.user_fgt_eip_public[each.key]
    swagger_url      = "http://${var.user_fgt_eip_public[each.key]}:${var.app2_mapped_port}"
  }
}