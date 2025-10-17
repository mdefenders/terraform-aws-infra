variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "bastion_enabled" {
  type        = bool
  description = "Whether to create the bastion host EC2 instance"
}

variable "bastion_instance_type" {
  type        = string
  description = "EC2 instance type for bastion host"
}

variable "bastion_ami_id" {
  type        = string
  description = "Optional explicit AMI ID for the bastion host. If null, latest Amazon Linux 2 is used."
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}
variable "bastion_subnet_id" {
  description = "The ID of the subnet where the bastion host will be deployed"
  type        = string
}
