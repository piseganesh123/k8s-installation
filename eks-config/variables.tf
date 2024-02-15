# Variables for AWS infrastructure module

variable "aws_region" {
  type        = string
  description = "AWS region used for all resources."
  default     = "ap-south-1"
}

# Local variables used to reduce repetition
locals {
  node_username = "awsuser"
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "qs"
}