# environnement de déploiement
variable "namespace" {
  type = string
}
variable "environment" {
  type    = string
  default = "dev"
}
# VPC
variable "vpc" {
  type = any
}
# paire de clé utilisée
variable key_name {
  type = string
}

# db name
variable "wordpress_db" {
  type = string
}

# db user
variable "db_user" {
  type = string
}

# db pwd
variable "db_pwd" {
  type = string
}

# db isntance name
variable "db_instance_name" {
  type = string
}

variable "wordpress_db_enpoint" {
  type = string
}

variable "sg_public_ports_ingress" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22,80,443]
}
variable "sg_public_ports_egress" {
type       = list(number)
description = "list of egress ports"
default     = [-1]
}
variable "sg_private_ports_ingress" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22,80,443,3306]
}
variable "sg_private_ports_egress" {
type       = list(number)
description = "list of egress ports"
default     = [-1]
}
variable "sg_rds_id" {
  type = string
}