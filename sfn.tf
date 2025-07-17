############
# EC2 Logic
############
resource "aws_sfn_state_machine" "ec2_logic" {
  name     = "${local.base_name}-ec2-logic"
  role_arn = aws_iam_role.ec2_logic.arn
  type     = "EXPRESS"

  definition = jsonencode({
    Comment = "Discord API for EC2 manager"
    StartAt = "VerifySignature"
    States = {
      VerifySignature = {
        Type     = "Task"
        Resource = aws_lambda_function.verify_signature.arn
        Next     = "ChoiceState"
      },
      ChoiceState = {
        Type    = "Choice"
        Default = "Ping"
        Choices = [
          {
            Variable      = "$.interaction_type"
            NumericEquals = 1
            Next          = "Ping"
          },
          {
            Variable      = "$.interaction_type"
            NumericEquals = 2
            Next          = "EC2Manager"
          }
        ]
      },
      Ping = {
        Type     = "Task"
        Resource = aws_lambda_function.ping.arn
        End      = true
      },
      EC2Manager = {
        Type     = "Task"
        Resource = aws_lambda_function.ec2_manager.arn
        End      = true
      }
    }
  })

  logging_configuration {
    level                  = "ALL"
    include_execution_data = true
    log_destination        = "${aws_cloudwatch_log_group.ec2_logic.arn}:*"
  }

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ec2-logic"
  })
}

resource "aws_cloudwatch_log_group" "ec2_logic" {
  name              = "/aws/stepfunctions/${local.base_name}-ec2-logic"
  retention_in_days = var.cloudwatch_retention

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-ec2-logic"
  })
}
