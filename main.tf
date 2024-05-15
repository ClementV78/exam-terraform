provider "aws" {
  region     = "eu-west-3"
  access_key = var.AWS_ACCESS_KEY_ID                   # la clé d’accès crée pour l'utilisateur qui sera utilisé par terraform
  secret_key = var.AWS_SECRET_ACCESS_KEY  # la clé sécrète crée pour l'utilisateur qui sera utilisé par terraform
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
  source    = "./modules/networking"
  namespace = var.namespace
}
# appel du modules ec2
/* module "ec2" {
  source     = "./modules/ec2"
  namespace  = var.namespace
  vpc        = module.networking.vpc
  sg_pub_id  = module.networking.sg_pub_id
  sg_priv_id = module.networking.sg_priv_id
  key_name   = "Datascientest"
}*/