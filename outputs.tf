output "vault_asg_id" {
  value = "${element(concat(aws_autoscaling_group.vault.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "vault_sg_id" {
  value = "${module.vault_server_sg.vault_server_sg_id}"
}

output "vault_username" {
  value = "${lookup(var.users, var.os)}"
}
