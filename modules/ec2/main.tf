#Créez une Data Source aws_ami pour sélectionner l'ami disponible dans votre région
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

locals {
  vars = {
    db_root_password="${var.wordpress_db}"
    db_username="${var.db_user}"
    db_user_password="${var.db_pwd}"
    db_name="${var.wordpress_db}"
    db_RDS= "${var.wordpress_db_enpoint}"
    db_rds_instance_name="${var.wordpress_db_enpoint}"
  }
  to_tag = ["instance", "network-interface"]
}

resource "aws_launch_template" "template-ec2-wordpress" {
  name_prefix     = "${var.namespace}-ec2-wordpress-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  update_default_version = true
  //vpc_security_group_ids = [var.sg_priv_id]
  //user_data                   = file("${path.module}/install_wordpress.sh")
  network_interfaces {
    security_groups   =  [aws_security_group.sg_priv_sub.id]
    associate_public_ip_address = true
  }
  user_data = base64encode(templatefile("${path.module}/install_wordpress.sh", local.vars))
  dynamic "tag_specifications" {
    for_each = toset(local.to_tag)
    content {
       resource_type = tag_specifications.key
       tags = {
          Terraform = "true"
          Author = "cviot"
          Environment = "dev"
          Module = "ec2"
          Name = "${var.namespace}-ec2-launchtemplate-wordpress"
        }
    }
  } 
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Module = "ec2"
    Name = "${var.namespace}-ec2-launchtemplate-wordpress"
  }
}

resource "aws_autoscaling_group" "alb_autoscaling_group" {
  name                  = "${var.namespace}-wordpress-autoscaling-group"  
  vpc_zone_identifier   =  var.vpc.private_subnets
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  launch_template {
    id      = aws_launch_template.template-ec2-wordpress.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "bastion-ec2-template" {
  name_prefix     = "${var.namespace}-ec2-bastion-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  update_default_version = true
  #vpc_security_group_ids = [var.sg_pub_id]
  network_interfaces {
    associate_public_ip_address = true
    security_groups   =  [aws_security_group.sg_pub_sub.id]
  }
  dynamic "tag_specifications" {
    for_each = toset(local.to_tag)
    content {
       resource_type = tag_specifications.key
       tags = {
          Terraform = "true"
          Author = "cviot"
          Environment = "dev"
          Module = "ec2"
          Name = "${var.namespace}-ec2-launchtemplate-bastion"
        }
    }
  } 
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Module = "ec2"
    Name = "${var.namespace}-ec2-launchtemplate-bastion"
  }
}

resource "aws_autoscaling_group" "bastion_autoscaling_group" {
  name                  = "${var.namespace}-bastion-autoscaling-group"  
  vpc_zone_identifier   =  var.vpc.public_subnets
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  launch_template {
    id      = aws_launch_template.bastion-ec2-template.id
    version = "$Latest"
  }
  
  
}


# Zone hébergée Route 53 pour le sous-domaine
resource "aws_route53_zone" "my_subdomain" {
  name = "exam-tf.0xclem.cloudns.ch"
}

# SSL Certificate avec validation DNS
resource "aws_acm_certificate" "my_certificate" {
  domain_name       = "exam-tf.0xclem.cloudns.ch"
  validation_method = "DNS"

  tags = {
    Name        = "${var.namespace} exam-tf.0xclem.cloudns.ch SSL certificate"
    Terraform   = "true"
    Author      = "cviot"
    Environment = "dev"
    Module      = "alb"
  }
}

# DNS validation record
resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.my_subdomain.zone_id
  ttl = 60
}


resource "aws_acm_certificate_validation" "my-certificate" {
  certificate_arn         = aws_acm_certificate.my_certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  enable_deletion_protection = false
  name    = "${var.namespace}-alb"
  vpc_id  = var.vpc.vpc_id
  subnets = var.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc.vpc_cidr_block
    }
  }

  target_groups = {
    wordpress_target_group = {
      #name     = "${var.namespace}-wordpress-tg"
      name_prefix                       = "h1"
      port     = 80
      protocol = "HTTP"
      target_type                       = "instance"
      create_attachment = false
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = true
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"  # ou HTTPS
        matcher             = "200-399"
      }

    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      /*forward = {
        target_group_key = "wordpress_target_group"
      }*/
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "${aws_acm_certificate.my_certificate.arn}"

      forward = {
        target_group_key = "wordpress_target_group"
      }
    }
  }  
  tags = {
    Terraform = "true"
    Author = "cviot"
    Environment = "dev"
    Module = "alb"
    Name = "${var.namespace}-alb"
  }
}

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

resource "aws_vpc_security_group_ingress_rule" "sg_in_ec2_alb_80" {
  security_group_id = aws_security_group.sg_priv_sub.id
  referenced_security_group_id = module.alb.security_group_id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "sg_in_ec2_alb_443" {
  security_group_id = aws_security_group.sg_priv_sub.id
  referenced_security_group_id = module.alb.security_group_id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}


resource "aws_vpc_security_group_ingress_rule" "sg_in_rds_ec2_3306" {
  security_group_id = var.sg_rds_id
  referenced_security_group_id = aws_security_group.sg_priv_sub.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}


# Enregistrement DNS dans Route 53 pour le Load Balancer
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_subdomain.zone_id
  name    = "exam-tf.0xclem.cloudns.ch"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.alb_autoscaling_group.id
  #lb_target_group_arn   = aws_lb_target_group.wordpress_target_group.arn
  lb_target_group_arn   = module.alb.target_groups["wordpress_target_group"].arn
}