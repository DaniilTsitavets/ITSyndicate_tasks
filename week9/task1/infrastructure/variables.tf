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

variable "isolated_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.1.5.0/24", "10.1.6.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "allocated_storage" {
  type    = number
  default = 5
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "17.2"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}