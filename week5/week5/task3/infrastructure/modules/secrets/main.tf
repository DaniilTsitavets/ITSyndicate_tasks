data "aws_ssm_parameter" "db_username" {
  name = "/task3_db_username"
  with_decryption = true
}

data "aws_ssm_parameter" "db_password" {
  name = "/task3_db_password"
  with_decryption = true
}

data "aws_ssm_parameter" "db_name" {
  name = "/task3_db_name"
  with_decryption = true
}
