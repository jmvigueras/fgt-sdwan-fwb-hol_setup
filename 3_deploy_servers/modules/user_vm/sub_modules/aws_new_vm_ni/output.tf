output "vm" {
  value = {
    adminuser  = var.linux_os == "ubuntu" ? "ubuntu" : "ec2-user"
    private_ip = var.iam_profile == null ? aws_instance.vm.*.private_ip[0] : aws_instance.vm_iam_profile.*.private_ip[0]
    id = var.iam_profile == null ? aws_instance.vm.*.id[0] : aws_instance.vm_iam_profile.*.id[0]
  }
}