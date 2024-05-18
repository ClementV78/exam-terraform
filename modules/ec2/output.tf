output "alb_dns_name" {
  value = module.alb.dns_name
}

output "route53_ns" {
  value = aws_route53_zone.my_subdomain.name_servers
}