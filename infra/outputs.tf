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

output "rds_password_ssm_parameter_name" {
  description = "The name of the SSM Parameter Store parameter for the DB password"
  value       = aws_ssm_parameter.db_password.name
}
