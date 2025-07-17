#################
# Layer - common
#################
data "archive_file" "common" {
  type        = "zip"
  source_dir  = "${path.module}/common"
  output_path = "${local.temp_dir}/${var.application_name}/common.zip"
}

resource "aws_lambda_layer_version" "common" {
  layer_name  = "${local.base_name}-layer-common"
  description = "Common dependencies for all, ${var.application_name}, lambdas functionality."

  filename            = data.archive_file.common.output_path
  source_code_hash    = data.archive_file.common.output_base64sha256
  compatible_runtimes = [var.python_version]
}

###################
# Ping interaction
###################
data "archive_file" "ping" {
  type        = "zip"
  source_file = "${path.module}/lambdas/ping.py"
  output_path = "${local.temp_dir}/${var.application_name}/ping.zip"
}

resource "aws_lambda_function" "ping" {
  function_name = "${local.base_name}-ping"
  role          = aws_iam_role.ping.arn

  filename         = data.archive_file.ping.output_path
  source_code_hash = data.archive_file.ping.output_base64sha256
  handler          = "ping.lambda_handler"
  runtime          = var.python_version
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  environment {
    variables = {
      LOG_LEVEL = var.log_level
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ping"
  })
}

resource "aws_cloudwatch_log_group" "ping" {
  name              = "/aws/lambda/${aws_lambda_function.ping.function_name}"
  retention_in_days = var.cloudwatch_retention

  tags = merge(local.common_tags, {
    Name = aws_lambda_function.ping.function_name
  })
}

#########################
# Signature verification
#########################
data "archive_file" "verify_signature" {
  type        = "zip"
  source_file = "${path.module}/lambdas/verify_signature.py"
  output_path = "${local.temp_dir}/${var.application_name}/verify_signature.zip"
}

resource "aws_lambda_function" "verify_signature" {
  function_name = "${local.base_name}-verify-signature"
  role          = aws_iam_role.verify_signature.arn

  filename         = data.archive_file.verify_signature.output_path
  source_code_hash = data.archive_file.verify_signature.output_sha256
  handler          = "verify_signature.lambda_handler"
  runtime          = var.python_version
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  environment {
    variables = {
      LOG_LEVEL               = var.log_level
      DISCORD_PUBLIC_KEY_NAME = "/${local.discord_public_key_name}"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-verify-signature"
  })
}

resource "aws_cloudwatch_log_group" "verify_signature" {
  name              = "/aws/lambda/${aws_lambda_function.verify_signature.function_name}"
  retention_in_days = var.cloudwatch_retention

  tags = merge(local.common_tags, {
    Name = aws_lambda_function.verify_signature.function_name
  })
}

##############
# EC2 Manager
##############
data "archive_file" "ec2_manager" {
  type        = "zip"
  source_file = "${path.module}/lambdas/ec2_manager.py"
  output_path = "${local.temp_dir}/${var.application_name}/ec2_manager.zip"
}

resource "aws_lambda_function" "ec2_manager" {
  function_name = "${local.base_name}-ec2-manager"
  role          = aws_iam_role.ec2_manager.arn

  filename         = data.archive_file.ec2_manager.output_path
  source_code_hash = data.archive_file.ec2_manager.output_sha256
  handler          = "ec2_manager.lambda_handler"
  runtime          = var.python_version
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  environment {
    variables = {
      LOG_LEVEL = var.log_level
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ec2-manager"
  })
}

resource "aws_cloudwatch_log_group" "ec2_manager" {
  name              = "/aws/lambda/${aws_lambda_function.ec2_manager.function_name}"
  retention_in_days = var.cloudwatch_retention

  tags = merge(local.common_tags, {
    Name = aws_lambda_function.ec2_manager.function_name
  })
}
