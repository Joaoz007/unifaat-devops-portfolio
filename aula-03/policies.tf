resource "aws_iam_policy" "s3_read" {
  name        = "${var.ra}-technova-s3-read"
  description = "Permite leitura de objetos e listagem dos buckets TechNova"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListTechNovaBuckets"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::technova-*"
      },
      {
        Sid    = "ReadTechNovaObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "arn:aws:s3:::technova-*/*"
      }
    ]
  })
}


resource "aws_iam_group_policy_attachment" "developers_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}



resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${var.ra}-technova-ec2-s3-full"
  description = "Permite gerenciamento controlado de EC2 e leitura/escrita em S3"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DescribeEC2"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVolumes",
          "ec2:DescribeImages"
        ]

        Resource = "*"
      },
      {
        Sid    = "StartStopTaggedInstances"
        Effect = "Allow"

        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]

        Resource = "arn:aws:ec2:*:*:instance/*"

        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Project" = "TechNova"
          }
        }
      },
      {
        Sid    = "S3ReadWrite"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-*",
          "arn:aws:s3:::technova-*/*"
        ]
      }
    ]
  })
}


resource "aws_iam_group_policy_attachment" "platform_ec2_s3" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}



resource "aws_iam_policy" "deny_destructive" {
  name        = "${var.ra}-technova-deny-destructive"
  description = "Impede operacoes destrutivas para o grupo de desenvolvedores"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyDestructiveActions"
        Effect = "Deny"

        Action = [
          "s3:Delete*",
          "ec2:Terminate*"
        ]

        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}