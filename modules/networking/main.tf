# recupère dynamiquement les zones de disponibilités
data "aws_availability_zones" "available" {}

/**********************
*  VPC
***********************/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.available.names
  public_subnets                   = ["10.0.120.0/20", "10.0.32.0/19"]
  private_subnets                  = ["10.0.0.0/19", "10.0.2.0/24"]
  #assign_generated_ipv6_cidr_block = true
  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = false
  one_nat_gateway_per_az = true
  manage_default_network_acl = true

  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Name = "${var.namespace}-vpc"
  }
}

/**********************
*  SG Public Subnet
***********************/
resource "aws_security_group" "sg_pub_sub" {
  name        = "sg_pub_sub"
  description = "groupe de sécurité pour autoriser le traffic ssh et http(s) vers le subnet public"

  dynamic "ingress" { 
    for_each = var.sg_public_ports_ingress 
    iterator = port 
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress"  {   

    for_each = var.sg_public_ports_ingress
    iterator = egress 
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

    tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Name = "${var.namespace}-sg_pub_sub"
  }
}

/**********************
*  SG Private Subnet
***********************/
resource "aws_security_group" "sg_priv_sub" {
  name        = "sg_priv_sub"
  description = "Autoriser le trafic entrant SSH depuis le public sunet"

  dynamic "ingress" { 
    for_each = var.sg_private_ports_ingress
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  }

  dynamic "egress"  { 

    for_each = var.sg_private_ports_egress
    iterator = egress # variable temporaire
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

    tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Name = "${var.namespace}-sg_priv_sub"
  }
}

