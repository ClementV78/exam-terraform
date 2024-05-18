/***********************************
*  Module ALB
***********************************/
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
      name_prefix                       = "h1"
      port     = 80
      /*
        * TODO : set to HTTPS
        */
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
        /*
        * TODO : set to HTTPS
        */
        protocol            = "HTTP"  # ou HTTPS
        matcher             = "200-399"
      }

    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "${var.my_certificate.arn}"

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

/***********************************
*  Definition de l'autoscaling group wordpress comme target group de l'ALB
***********************************/
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.alb_autoscaling_group.id
  lb_target_group_arn   = module.alb.target_groups["wordpress_target_group"].arn
}