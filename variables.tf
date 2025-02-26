 variable "aws_region" {
  description = "The AWS region to deploy resources."
  default     = "us-east-1"
}

variable "slack_bot_token" {
  description = "The OAuth token for the Slack bot."
  type        = string
}

variable "slack_signing_secret" {
  description = "The signing secret for verifying Slack requests."
  type        = string
}
