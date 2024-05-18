# recupère dynamiquement les zones de disponibilites
data "aws_availability_zones" "available" {}

/**********************
*  VPC
***********************/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = var.vpc_cidr
  azs                              = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1]]
  public_subnets                   = var.public_subnets
  private_subnets                  = var.private_subnets
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway               = true
  one_nat_gateway_per_az = true
  manage_default_network_acl = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Name = "${var.namespace}-vpc"
  }
  
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
}