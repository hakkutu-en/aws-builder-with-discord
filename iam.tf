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

##############
# EC2 Manager
##############
resource "aws_iam_role" "ec2_manager" {
  name = "${local.base_name}-ec2-manager"

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
    Name = "${local.base_name}-ec2-manager"
  })
}

resource "aws_iam_policy" "ec2_manager" {
  name        = aws_iam_role.ec2_manager.name
  description = "IAM policy for ec2_manager lambda function"

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
          aws_cloudwatch_log_group.ec2_manager.arn
        ]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = aws_iam_role.ec2_manager.name
  })
}

resource "aws_iam_role_policy_attachment" "ec2_manager" {
  role       = aws_iam_role.ec2_manager.name
  policy_arn = aws_iam_policy.ec2_manager.arn
}

resource "aws_iam_role_policy_attachment" "ec2_manager_lambda_basic_exec" {
  role       = aws_iam_role.ec2_manager.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

############
# EC2 Logic
############
resource "aws_iam_role" "ec2_logic" {
  name = "${local.base_name}-ec2-logic"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ec2-logic"
  })
}

resource "aws_iam_policy" "ec2_logic" {
  name        = aws_iam_role.ec2_logic.name
  description = "IAM policy for ec2-logic state machine"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          aws_lambda_function.verify_signature.arn,
          aws_lambda_function.ping.arn,
          aws_lambda_function.ec2_manager.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${aws_iam_role.ec2_logic.name}"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_logic" {
  role       = aws_iam_role.ec2_logic.name
  policy_arn = aws_iam_policy.ec2_logic.arn
}

###################
# Interactions API
###################
resource "aws_iam_role" "interactions_api" {
  name = "${local.base_name}-interactions-api"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-interactions-api"
  })
}

resource "aws_iam_policy" "interactions_api" {
  name        = aws_iam_role.interactions_api.name
  description = "IAM policy for interactions_api API Gateway"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartSyncExecution"
        ]
        Resource = [
          aws_sfn_state_machine.ec2_logic.arn
        ]
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = aws_iam_role.interactions_api.name
  })
}

resource "aws_iam_role_policy_attachment" "interactions_api" {
  role       = aws_iam_role.interactions_api.name
  policy_arn = aws_iam_policy.interactions_api.arn
}
