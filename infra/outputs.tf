output "kms_key_arn" {
  value = module.kms.key_arn
}

output "kms_key_id" {
  value = module.kms.key_id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = module.rds.db_instance_address
}

output "unsesal_kms_role" {
  value = aws_iam_role.role_vault_kms.arn
}

output "db_instance_master_user_secret_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}
