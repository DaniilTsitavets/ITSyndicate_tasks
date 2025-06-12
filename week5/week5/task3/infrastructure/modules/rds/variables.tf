variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
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

variable "db_subnet_group_name" {
  type = string
}

variable "rds_sg_id" {
  type = string
}