##
# INPUTS
##
variable "vpc_id" {
  type = "string"
}

variable "consul_sg_id" {
	type = "string"
}

variable "consul_host" {
  type = "string"
}


variable "subnets" {
  type = "list"
}

variable "cluster_size" {
  default = "3"
}

variable "cluster_name" {
  default = "vault"
}

variable "sshkey" {
  description = "Name of the SSH key used to access system"
}

variable "OS" {
  default = "RHEL"
  description = "Operating System to use. So far only RHEL supported. Ubuntu will be supported soon"
}

variable "OS-Version" {
  default = "7.3"
  description = "Operating System Version. I.E. 7.3 for RHEL or 14.04 for Ubuntu."
}

variable "Vault-Version" {
  default = "0.7.0"
  description = "Vault Product Version"
}

variable "region" {
  default = "us-west-1"
  description = "Region where this consul cluster will live. Used to find out Cluster members"
}

variable "instance_type" {
  default = "m4.large"
}

##
# OUTPUTS
##

output "vault_instance_sg" {
  value = "${aws_security_group.vault_instance.id}"
}
