variable "namespace" {
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
default     = [0]
}
variable "sg_private_ports_ingress" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22,80,443]
}
variable "sg_private_ports_egress" {
type       = list(number)
description = "list of egress ports"
default     = [0]
}