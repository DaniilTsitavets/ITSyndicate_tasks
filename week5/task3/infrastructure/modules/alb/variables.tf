variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "ec2_instance_ids" {
  type = list(string)
}