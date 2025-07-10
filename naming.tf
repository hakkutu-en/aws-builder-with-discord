locals {
  environment = terraform.workspace
  common_tags = {
    Region      = var.region
    Business    = var.business_name
    DeployedBy  = var.deployed_by
    ManagedBy   = "Terraform"
    Environment = local.environment
    Application = var.application_name
  }

  region_shorthand = {
    "af-south-1" = "afs1"
  }

  base_name = join("-", [
    local.region_shorthand[var.region],
    local.environment,
    var.business_name,
    var.application_name,
  ])

  temp_dir = "/tmp"

  discord_public_key_name = join("/", [
    var.business_name,
    local.environment,
    var.application_name,
    "public-key"
  ])
}
