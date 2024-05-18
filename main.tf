provider "aws" {
  region     = "eu-west-3"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "networking" {
  source          = "./modules/networking"
  namespace       = var.namespace
  environment     = var.environment
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  vpc_cidr        = var.vpc_cidr
}

module "acm" {
  source    = "./modules/acm"
  namespace = var.namespace
}

module "rds" {
  source           = "./modules/rds"
  namespace        = var.namespace
  environment      = var.environment
  db_pwd           = var.MYSQL_DB_PWD
  db_user          = var.MYSQL_DB_USER
  db_instance_name = var.db_instance_name
  vpc              = module.networking.vpc
}


# appel du modules ec2
module "ec2" {
  source               = "./modules/ec2"
  namespace            = var.namespace
  environment          = var.environment
  vpc                  = module.networking.vpc
  sg_rds_id            = module.rds.sg_rds_id
  db_pwd               = var.MYSQL_DB_PWD
  db_user              = var.MYSQL_DB_USER
  wordpress_db         = var.wordpress_db
  wordpress_db_enpoint = module.rds.wordpress_db_enpoint
  db_instance_name     = var.db_instance_name
  key_name             = var.key_name
  my_certificate       = module.acm.my_certificate
}

module "route53" {
  source         = "./modules/route53"
  namespace      = var.namespace
  alb_dns_name   = module.ec2.alb_dns_name
  alb_zone_id    = module.ec2.alb_zone_id
  my_certificate = module.acm.my_certificate
}

