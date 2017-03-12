variable "name" {
	type = "string"
}

variable "vpc_id" {
	type = "string"
}

variable "private_subnet_ids" {
	type = "list"
}

variable "consul_sg_id" {
	type = "string"
}

variable "ami" {
	type = "string"
}

variable "instance_type" {
	type = "string"
}

variable "instance_count" {
	type = "string"
}

variable "tls_key_bucket_arn" {
	type = "string"
}

variable "tls_kms_arn" {
	type = "string"
}

variable "tls_key_bucket_name" {
	type = "string"
}

variable "vault_circonus_token" {
	type = "string"
}
