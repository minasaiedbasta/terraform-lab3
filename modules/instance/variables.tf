variable vpc_id {
  type = string
}

variable instance_type {
  type = string
}

variable "az1_public_subnet_id" {
  type = string
}

variable "az1_private_subnet_id" {
  type = string
}

variable "az2_public_subnet_id" {
  type = string
}

variable "az2_private_subnet_id" {
  type = string
}

variable "private_load_balancer_dns" {
  type = string
}

variable "public_lb_sg_id" {
  type = string
}

variable "private_lb_sg_id" {
  type = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}
