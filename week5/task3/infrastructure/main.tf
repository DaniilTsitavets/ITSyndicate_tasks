module "vpc" {
  source = "modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
  azs = ["eu-north-1a", "eu-north-1b"]
  public_subnet_cidr_blocks = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnet_cidr_blocks = ["10.0.3.0/24"]
  isolated_subnet_cidr_blocks = ["10.0.5.0/24", "10.0.6.0/24"]

  region = "eu-north-1"
}

module "s3" {
  source = "modules/s3"
}

module "sg" {
  source = "modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "secrets" {
  source = "modules/secrets"
}

module "rds" {
  source               = "modules/rds"
  db_name              = module.secrets.db_name
  db_password          = module.secrets.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_username          = module.secrets.db_username
  rds_sg_id            = module.sg.rds_sg_id

  depends_on = [module.secrets]
}

module "iam" {
  source = "modules/iam"
  bucket_arn = module.s3.bucket_arn
}

module "ec2" {
  source                    = "modules/ec2"
  ec2_sg                    = module.sg.ec2_sg_id
  iam_instance_profile_name = module.iam.iam_instance_profile_name
  private_subnet_id         = module.vpc.private_subnet_ids[0]
  rds_host                  = module.rds.rds_address

  depends_on = [module.rds, module.iam]
}

module "alb" {
  source = "modules/alb"
  alb_sg_id = module.sg.alb_sg_id
  ec2_instance_ids = module.ec2.ec2_instance_ids
  public_subnets = module.vpc.public_subnet_ids
  vpc_id = module.vpc.vpc_id
}

module "waf" {
  source = "modules/waf"
  alb_arn = module.alb.alb_arn
}
