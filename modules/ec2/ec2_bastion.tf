/***********************************
*  Template EC2 Bastion
***********************************/
resource "aws_launch_template" "bastion-ec2-template" {
  name_prefix     = "${var.namespace}-ec2-bastion-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  update_default_version = true
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

/***********************************
*   Autoscaling group Bastion
***********************************/
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