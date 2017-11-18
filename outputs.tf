output "vault_asg_id" {
  value = "${aws_autoscaling_group.vault_server.id}"
}

output "vault_sg_id" {
  value = "${module.vault_server_sg.vault_server_sg_id}"
}

output "vault_username" {
  value = "${lookup(var.users, var.os)}"
}
