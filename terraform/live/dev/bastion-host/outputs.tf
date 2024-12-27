output "id" {
  description = "The ID of the instance"
  value       = module.bastion_host.id
}

output "arn" {
  description = "The ARN of the instance"
  value       = module.bastion_host.arn
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = module.bastion_host.public_ip
}

output "ami" {
  description = "AMI ID that was used to create the instance"
  value       = module.bastion_host.ami
}

output "availability_zone" {
  description = "The availability zone of the created instance"
  value       = module.bastion_host.availability_zone
}

output "sg_bastion_host_id" {
  description = "The ID of the Bastion Host security group"
  value       = module.sg_bastion_host.security_group_id
}
