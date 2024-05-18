variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "cviot-exam-tf"
  type        = string
}

variable "region" {
  description = "AWS région"
  default     = "eu-west-3"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}
variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "MYSQL_DB_USER" {
  type = string
}

variable "MYSQL_DB_PWD" {
  type = string
}

# db instance name
variable "db_instance_name" {
  type    = string
  default = "mysql-wordpress"
}

# db instance name
variable "wordpress_db" {
  type    = string
  default = "wordpress"
}

variable "key_name" {
  type    = string
  default = "cviot_keypair"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/24"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

