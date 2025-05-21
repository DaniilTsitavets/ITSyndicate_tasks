variable "env_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_az" {
  type = list(string)
}

variable "demo_public_subnet_cidr_blocks" {
  type = list(string)
}
