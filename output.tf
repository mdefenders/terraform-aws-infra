output "bastion_role_name" {
  value       = try(aws_iam_role.bastion[0].name, null)
  description = "IAM role name for the bastion host (null if not created)."
}

output "bastion_instance_profile_name" {
  value       = try(aws_iam_instance_profile.bastion[0].name, null)
  description = "Instance profile name attached to bastion (null if not created)."
}

output "bastion_id" {
  value       = aws_instance.bastion.id
  description = "Bastion host EC2 instance ID (null if not created)."
}
