output "vpc" {
  value = module.vpc
}

output "sg_pub_id" {
  value = aws_security_group.sg_pub_sub.id
}

output "sg_priv_id" {
  value = aws_security_group.sg_priv_sub.id
}