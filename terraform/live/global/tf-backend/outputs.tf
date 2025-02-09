output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.terraform_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket."
  value       = module.terraform_bucket.s3_bucket_arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = aws_dynamodb_table.main.name
}
