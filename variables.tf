variable "region" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "subnets" {
  type = list(object({
    type = string
    cidr_block = string,
  }))
}

variable "instance_type" {
  type = string
}

variable "public_key_location" {
  type = string
}

variable "private_key_location" {
  type = string
}
