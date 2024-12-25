################################################################################
# Cognito User Pool
################################################################################

output "id" {
  description = "The id of the user pool"
  value       = module.cognito_user_pool.id
}

output "arn" {
  description = "The ARN of the user pool"
  value       = module.cognito_user_pool.arn
}

output "client_ids_map" {
  description = "The ids map of the user pool clients"
  value       = module.cognito_user_pool.client_ids_map
}

output "client_secrets_map" {
  description = "The client secrets map of the user pool clients"
  value       = module.cognito_user_pool.client_secrets_map
  sensitive   = true
}

################################################################################
# Secrets Manager
################################################################################

output "secret_id" {
  description = "The ID of the secret"
  value       = module.cognito_user_pool_secrets.secret_id
}

output "secret_arn" {
  description = "The ARN of the secret"
  value       = module.cognito_user_pool_secrets.secret_arn
}

output "secret_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = module.cognito_user_pool_secrets.secret_version_id
}
