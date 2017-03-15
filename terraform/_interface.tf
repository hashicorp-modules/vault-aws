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
