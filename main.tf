# Bastion host (optional)
# Fetch latest Amazon Linux 2 AMI if no explicit bastion_ami_id provided
data "aws_ami" "bastion" {
  count       = var.bastion_enabled && var.bastion_ami_id == "null" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "bastion" {
  count       = var.bastion_enabled ? 1 : 0
  name        = "${var.vpc_name}-bastion-sg"
  description = "Bastion Open Egress Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-bastion-sg"
    Role = "bastion"
  })
}

resource "aws_iam_role" "bastion" {
  count       = var.bastion_enabled ? 1 : 0
  name        = "BastionRole"
  description = "IAM role for bastion host to allow SSM access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-bastion-role"
    Role = "bastion"
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  count      = var.bastion_enabled ? 1 : 0
  role       = aws_iam_role.bastion[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  name  = "${var.vpc_name}-bastion-instance-profile"
  role  = aws_iam_role.bastion[0].name
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-bastion-instance-profile"
    Role = "bastion"
  })
}

resource "aws_instance" "bastion" {
  count                  = var.bastion_enabled ? 1 : 0
  ami                    = var.bastion_ami_id != "null" ? var.bastion_ami_id : data.aws_ami.bastion[0].id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.bastion_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum remove awscli
    cd
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf ./aws awscliv2.zip
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
  EOF

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-bastion"
    Role = "bastion"
  })
}
