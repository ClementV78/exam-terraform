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

