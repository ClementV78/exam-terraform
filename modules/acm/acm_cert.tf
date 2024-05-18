/***********************************
*  Certificat ACM
***********************************/
# SSL Certificate avec validation DNS
resource "aws_acm_certificate" "my_certificate" {
  domain_name       = "exam-tf.0xclem.cloudns.ch"
  validation_method = "DNS"

  tags = {
    Name        = "${var.namespace} exam-tf.0xclem.cloudns.ch SSL certificate"
    Terraform   = "true"
    Author      = "cviot"
    Environment = "dev"
    Module      = "acm"
  }
}