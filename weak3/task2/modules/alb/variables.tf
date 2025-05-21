variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ASG"
  type = list(string)
}

variable "alb_sg" {
  type = string
}