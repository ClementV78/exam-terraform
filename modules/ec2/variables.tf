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
# id du groupe de sécurité public
variable "sg_pub_id" {
  type = any
}
# id du groupe de sécurité privée
variable "sg_priv_id" {
  type = any
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
