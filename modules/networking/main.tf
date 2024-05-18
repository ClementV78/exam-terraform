# recupère dynamiquement les zones de disponibilites
data "aws_availability_zones" "available" {}

/**********************
*  VPC
***********************/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1]]
  public_subnets                   = ["10.0.128.0/20" , "10.0.144.0/20"]
  private_subnets                  = ["10.0.0.0/19", "10.0.32.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway               = true
  one_nat_gateway_per_az = true
  manage_default_network_acl = true
  
  /*manage_default_route_table = true
  default_route_table_tags   = var.default_route_table_tags
  manage_default_security_group = true
  default_security_group_tags   = var.default_security_group_tags*/

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
  # Additional tags
  private_subnet_tags_per_az = {
    "${data.aws_availability_zones.available.names[0]}" = {
      Name : "priv_sub_az1-${data.aws_availability_zones.available.names[0]}"
    },
    "${data.aws_availability_zones.available.names[1]}" = {
      Name : "priv_sub_az2-${data.aws_availability_zones.available.names[1]}"
    }
  }
  public_subnet_tags_per_az = {
    "${data.aws_availability_zones.available.names[0]}" = {
      Name : "pub_sub_az1-${data.aws_availability_zones.available.names[0]}"
    },
    "${data.aws_availability_zones.available.names[1]}" = {
      Name : "pub_sub_az1-${data.aws_availability_zones.available.names[1]}"
    }
  }
  #vpc_tags                   = "vpc"
  default_network_acl_tags   = { Name: "acl"}
  nat_eip_tags               = { Name: "nat_eip"}
  nat_gateway_tags           = { Name: "nat_gateway"}
  private_acl_tags           = { Name: "private_acl"}
  igw_tags                   = { Name: "igw"}

  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-vpc"
  }

}

/*
resource "aws_subnet" "priv_sub_az1" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.0.0/19"
  
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-priv_sub_az1"
  }
}

resource "aws_subnet" "priv_sub_az2" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.32.0/24"
  
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-priv_sub_az2"
  }
}

resource "aws_subnet" "pub_sub_az1" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.128.0/20"
  
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-pub_sub_az1"
  }
}

resource "aws_subnet" "pub_sub_az2" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.144.0/20"
  
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-pub_sub_az2"
  }
}
*/

