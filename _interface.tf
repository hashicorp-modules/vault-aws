# Required variables
variable "cluster_name" {
  description = "Auto Scaling Group Cluster Name"
}

variable "consul_server_sg_id" {
  description = "Consul Server Security Group ID"
}

variable "environment_name" {
  description = "Environment Name (tagged to all instances)"
}

variable "os" {
  # case sensitive for AMI lookup
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

variable "ssh_key_name" {
  description = "Pre-existing AWS key name you will use to access the instance(s)"
}

variable "subnet_ids" {
  type        = "list"
  description = "Pre-existing Subnet ID(s) to use"
}

variable "vpc_id" {
  description = "Pre-existing VPC ID to use"
}

# Optional variables
variable "cluster_size" {
  default     = "3"
  description = "Number of instances to launch in the cluster eg 3"
}

variable "consul_as_server" {
  default     = "true"
  description = "Run the consul agent in server mode: true/false"
}

variable "instance_type" {
  default     = "m4.large"
  description = "AWS instance type to use eg m4.large"
}

variable "region" {
  default     = "us-west-1"
  description = "Region to deploy vault cluster ie us-west-1"
}

variable "vault_use_tls" {
  default     = "true"
  description = "Use TLS for vault communication: true/false"
}

variable "vault_version" {
  default     = "0.7.3"
  description = "Vault version to use ie 0.7.3"
}

# Outputs
output "asg_id" {
  value = "${aws_autoscaling_group.vault_server.id}"
}

output "vault_server_sg_id" {
  value = "${aws_security_group.vault_server.id}"
}
