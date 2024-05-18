variable "namespace" {
  type = string
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "vpc_cidr" {
  type = string
}