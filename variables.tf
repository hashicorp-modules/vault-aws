variable "name" {
  default     = "vault-aws"
  description = "Name for resources, defaults to \"vault-aws\"."
}

variable "release_version" {
  default     = "0.1.0-dev1"
  description = "Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to \"0.1.0-dev1\""
}

variable "vault_version" {
  default     = "0.8.1"
  description = "Vault version tag (e.g. 0.8.1 or 0.8.1-ent), defaults to \"0.8.1\"."
}

variable "os" {
  default     = "RHEL"
  description = "Operating System (e.g. RHEL or Ubuntu), defaults to \"RHEL\"."
}

variable "os_version" {
  default     = "7.3"
  description = "Operating System version (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to \"7.3\"."
}

variable "vpc_id" {
  description = "VPC ID to provision resources in."
}

variable "vpc_cidr" {
  description = "VPC CIDR block to provision resources in."
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet ID(s) to provision resources in."
}

variable "count" {
  default     = "-1"
  description = "Number of Vault nodes to provision across private subnets, defaults to private subnet count."
}

variable "public_ip" {
  default     = "false"
  description = "Associate a public IP address to the Vault nodes, defaults to \"false\"."
}

variable "instance_profile" {
  default     = ""
  description = "AWS instance profile to use."
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type for Vault node (e.g. \"m4.large\"), defaults to \"t2.small\"."
}

variable "user_data" {
  default     = ""
  description = "user_data script to pass in at runtime."
}

variable "ssh_key_name" {
  description = "AWS key name you will use to access the instance(s)."
}

variable "users" {
  default = {
    RHEL   = "ec2-user"
    Ubuntu = "ubuntu"
  }

  description = "Map of SSH users."
}
