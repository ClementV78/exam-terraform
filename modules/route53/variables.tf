# environnement de déploiement
variable "namespace" {
  type = string
}

variable "my_certificate" {
  type = any
}

variable "alb_dns_name" {
  type = string
}
variable "alb_zone_id" {
  type = string
}