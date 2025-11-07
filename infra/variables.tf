variable "project" {
  type        = string
  description = "Project Name."
  default     = "vault"
}

variable "cidr" {
  description = " VPC CIDR"
  default     = "10.0.0.0/16"
  type        = string
}

variable "vault_namespace" {
  description = "Namespace where fault would be installed."
  default     = "vault"
  type        = string
}

variable "vault_service_account_name" {
  description = "Service Account to be used by Vault."
  type        = string
  default     = "vault-sa"
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "demo_db"
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
  default     = "admin"
}
