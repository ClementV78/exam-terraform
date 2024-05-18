/***********************************
* Variables locales
***********************************/
locals {
  vars = {
    # Setter les variables d'environnement pour l'éxécution du script wordpress
    db_root_password="${var.wordpress_db}"
    db_username="${var.db_user}"
    db_user_password="${var.db_pwd}"
    db_name="${var.wordpress_db}"
    db_RDS= "${var.wordpress_db_enpoint}"
    db_rds_instance_name="${var.wordpress_db_enpoint}"
  }
  to_tag = ["instance", "network-interface"]
}

/***********************************
* Template EC2 wordpress
***********************************/
resource "aws_launch_template" "template-ec2-wordpress" {
  name_prefix     = "${var.namespace}-ec2-wordpress-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  update_default_version = true
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

/***********************************
*  Autoscaling group wordpress
***********************************/
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