variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "af-south-1"
}

variable "business_name" {
  description = "The name of the business."
  type        = string
  default     = "hakkutu"
}

variable "application_name" {
  description = "Name of the application."
  type        = string
  default     = "aws-builder-with-discord"
}

variable "python_version" {
  description = "The Python version to use."
  type        = string
  default     = "python3.13"
}

variable "lambda_memory_size" {
  description = "The memory size to use for the Lambda functions."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "The timeout to use for the Lambda functions."
  type        = number
  default     = 300
}

variable "lambda_architecture" {
  description = "The architecture of functions."
  type        = string
  default     = "arm64"
}

variable "cloudwatch_retention" {
  description = "The CloudWatch log group retention period."
  type        = number
  default     = 7
}

variable "log_level" {
  description = "The log level to use."
  type        = string
  default     = "DEBUG"
}

variable "deployed_by" {
  description = "The name of the person or location deploying the resources."
  type        = string
  default     = "hakkutu-en/aws-builder-with-discord"
}
