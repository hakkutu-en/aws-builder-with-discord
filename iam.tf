###################
# Ping interaction
###################
resource "aws_iam_role" "ping" {
  name = "${local.base_name}-ping"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ping"
  })
}

resource "aws_iam_policy" "ping" {
  name        = aws_iam_role.ping.name
  description = "IAM policy for ping lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.ping.arn
        ]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = aws_iam_role.ping.name
  })
}

resource "aws_iam_role_policy_attachment" "ping" {
  role       = aws_iam_role.ping.name
  policy_arn = aws_iam_policy.ping.arn
}

resource "aws_iam_role_policy_attachment" "ping_lambda_basic_exec" {
  role       = aws_iam_role.ping.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#########################
# Signature verification
#########################
resource "aws_iam_role" "verify_signature" {
  name = "${local.base_name}-verify-signature"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-verify-signature"
  })
}

resource "aws_iam_policy" "verify_signature" {
  name        = aws_iam_role.verify_signature.name
  description = "IAM policy for verify_signature lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.verify_signature.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          aws_ssm_parameter.discord_public_key.arn
        ]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = aws_iam_role.ping.name
  })
}

resource "aws_iam_role_policy_attachment" "verify_signature" {
  role       = aws_iam_role.verify_signature.name
  policy_arn = aws_iam_policy.verify_signature.arn
}

resource "aws_iam_role_policy_attachment" "verify_signature_lambda_basic_exec" {
  role       = aws_iam_role.verify_signature.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
