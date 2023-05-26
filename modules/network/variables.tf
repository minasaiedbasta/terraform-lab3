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