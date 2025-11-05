locals {
  vpc_cidr = var.cidr
  common_tags = {
    Project    = "vault"
    Enviroment = "demo"
    Owner      = "Bnay14"
  }
}


