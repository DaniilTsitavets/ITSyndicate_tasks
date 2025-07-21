data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/devops/prepared_ami"
}

module "bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "ansible-pk"
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "web" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "web"

  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t3.micro"
  key_name                    = "ansible-pk"
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "db" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "db"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "ansible-pk"
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.db.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}