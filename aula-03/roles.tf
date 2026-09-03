resource "aws_iam_role" "ec2_role" {
  name = "${var.ra}-technova-ec2-role"

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
}


resource "aws_iam_policy" "ec2_s3_role_policy" {
  name        = "${var.ra}-technova-ec2-s3-role-policy"
  description = "Permite leitura e escrita no S3 para instancias EC2"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-app-data-*",
          "arn:aws:s3:::technova-app-data-*/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_role_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ra}-technova-ec2-profile"
  role = aws_iam_role.ec2_role.name
}