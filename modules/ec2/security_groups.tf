/**********************
*  SG Public Subnet
***********************/
resource "aws_security_group" "sg_pub_sub" {
  name        = "sg_pub_sub"
  description = "groupe de securite pour autoriser le traffic ssh et http(s) vers le subnet public"
  vpc_id =  var.vpc.vpc_id
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

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Module = "networking"
    Name = "${var.namespace}-sg_pub_sub"
  }
}

/**********************
*  SG Private Subnet
***********************/
resource "aws_security_group" "sg_priv_sub" {
  name        = "sg_priv_sub"
  description = "Autoriser le trafic entrant SSH depuis le public sunet"
  vpc_id = var.vpc.vpc_id
  dynamic "ingress" { 
    for_each = var.sg_private_ports_ingress
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc.vpc_cidr_block]
    }
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "${var.environment}"
    Module = "networking"
    Name = "${var.namespace}-sg_priv_sub"
  }
}

/************************************************
*  Ajout ingress port 80 source ALB pour le Private Subnet
**************************************************/
resource "aws_vpc_security_group_ingress_rule" "sg_in_ec2_alb_80" {
  security_group_id = aws_security_group.sg_priv_sub.id
  referenced_security_group_id = module.alb.security_group_id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

/************************************************
*  Ajout ingress port 443 source ALB pour le Private Subnet
**************************************************/
resource "aws_vpc_security_group_ingress_rule" "sg_in_ec2_alb_443" {
  security_group_id = aws_security_group.sg_priv_sub.id
  referenced_security_group_id = module.alb.security_group_id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

/************************************************
*  Ajout ingress port 3306 source Private Subnet pour la base RDS
**************************************************/
resource "aws_vpc_security_group_ingress_rule" "sg_in_rds_ec2_3306" {
  security_group_id = var.sg_rds_id
  referenced_security_group_id = aws_security_group.sg_priv_sub.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}