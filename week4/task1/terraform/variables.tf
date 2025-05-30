variable "django_vpc_cidr" {
  description = "VPC cidr"
  type        = string
  default     = "10.1.0.0/16"
}

variable "django_subnet_az" {
  description = "AZs for public subnets"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "django_public_subnet_cidr" {
  description = "List of cidr's which are applied to AZs"
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.3.0/24"]
}

variable "django_private_subnet_cidr" {
  description = "List of cidr's which are applied to AZs"
  type        = list(string)
  default     = ["10.1.2.0/24", "10.1.4.0/24"]
}

variable "ami_id" {
  type = string
  default = "ami-04542995864e26699"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "region" {
  type = string
  default = "eu-north-1"
}