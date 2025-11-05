variable "project" {
  default = "vault"
}

variable "env" {
  default = "demo"
}


variable "cidr" {
  default = "10.0.0.0/16"
  type    = string
}
