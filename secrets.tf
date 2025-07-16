#####################
# Discord Public Key
#####################
resource "aws_ssm_parameter" "discord_public_key" {
  name        = "/${local.discord_public_key_name}"
  type        = "SecureString"
  description = "Discord public key for signature verification used by ${var.application_name}"

  overwrite = true
  value     = var.discord_public_key

  tags = merge(local.common_tags, {
    Name = "/${local.discord_public_key_name}"
  })
}
