provider "aws" {
  region     = "eu-west-3"
  access_key = var.AWS_ACCESS_KEY_ID     # la clé d’accès crée pour l'utilisateur qui sera utilisé par terraform
  secret_key = var.AWS_SECRET_ACCESS_KEY # la clé sécrète crée pour l'utilisateur qui sera utilisé par terraform
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# appel du modules networking
module "networking" {
  source      = "./modules/networking"
  namespace   = var.namespace
  environment = var.environment
}

module "rds" {
  source           = "./modules/rds"
  namespace        = var.namespace
  environment      = var.environment
  #sg_rds_id        = module.networking.sg_rds_id
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
  sg_pub_id            = module.networking.sg_pub_id
  sg_priv_id           = module.networking.sg_priv_id
  db_pwd               = var.MYSQL_DB_PWD
  db_user              = var.MYSQL_DB_USER
  wordpress_db         = var.wordpress_db
  wordpress_db_enpoint = module.rds.wordpress_db_enpoint
  db_instance_name     = var.db_instance_name
  key_name             = "cviot_keypair"
}

