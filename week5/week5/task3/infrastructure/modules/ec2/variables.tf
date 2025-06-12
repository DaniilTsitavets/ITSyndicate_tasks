variable "ami" {
  type = string
  default = "ami-04542995864e26699"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "iam_instance_profile_name" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "ec2_sg" {
  type = string
}

variable "rds_host" {
  type = string
}