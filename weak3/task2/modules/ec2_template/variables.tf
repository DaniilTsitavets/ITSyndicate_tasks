variable "ec2_ami_id" {
  type    = string
  default = "ami-0c1ac8a41498c1a9c"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_sg" {
  type = string
}