# =============================================================
# AMAZON LINUX 2023
# =============================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
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

# =============================================================
# KEY PAIR
# =============================================================

resource "aws_key_pair" "technova" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand("~/.ssh/technova-key.pub"))

  tags = {
    Name        = "${var.project_name}-key"
    Project     = "TechNova"
    Environment = "development"
    ManagedBy   = "Terraform"
    Owner       = "6325175"
  }
}

# =============================================================
# IAM ROLE
# =============================================================

resource "aws_iam_role" "technova_ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Project     = "TechNova"
    Environment = "development"
    ManagedBy   = "Terraform"
    Owner       = "6325175"
  }
}

# =============================================================
# IAM POLICY — S3 READ ONLY
# =============================================================

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.technova_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# =============================================================
# INSTANCE PROFILE
# =============================================================

resource "aws_iam_instance_profile" "technova" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.technova_ec2.name

  tags = {
    Name        = "${var.project_name}-ec2-profile"
    Project     = "TechNova"
    Environment = "development"
    ManagedBy   = "Terraform"
    Owner       = "6325175"
  }
}

# =============================================================
# EC2 — TECHNOVA API
# =============================================================

resource "aws_instance" "api" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.api.id
  ]

  key_name = aws_key_pair.technova.key_name

  iam_instance_profile = aws_iam_instance_profile.technova.name

  user_data = file("user_data.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.project_name}-ec2-api"
    Project     = "TechNova"
    Environment = "development"
    ManagedBy   = "Terraform"
    Owner       = "6325175"
  }
}
