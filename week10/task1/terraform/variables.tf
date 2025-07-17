variable "vpc_cidr_block" {
  type    = string
  default = "10.1.0.0/16"
}

variable "azs" {
  type = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "ami" {
  type = string
  default = "ami-04542995864e26699"
}

variable "bastion_instance_type" {
  type = string
  default = "t3.micro"
}

variable "other_nodes_instance_type" {
  type = string
  default = "t3.small"
}