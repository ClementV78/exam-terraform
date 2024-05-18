/***********************************
* Zone Route 53 
***********************************/
resource "aws_route53_zone" "my_subdomain" {
  name = "exam-tf.0xclem.cloudns.ch"
}

/***********************************
*  Record Route 53
***********************************/
# DNS validation record
resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name =  tolist(var.my_certificate.domain_validation_options)[0].resource_record_name
  records = [tolist(var.my_certificate.domain_validation_options)[0].resource_record_value]
  type = tolist(var.my_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.my_subdomain.zone_id
  ttl = 60
}

/***********************************
*  Validation certificat ACM
***********************************/
resource "aws_acm_certificate_validation" "my-certificate" {
  certificate_arn         = var.my_certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

/***********************************
*  Enregistrement DNS dans Route 53 pour le Load Balancer
***********************************/
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_subdomain.zone_id
  name    = "exam-tf.0xclem.cloudns.ch"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
