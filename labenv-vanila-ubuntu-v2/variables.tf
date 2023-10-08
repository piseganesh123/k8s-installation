# Variables for GCP infrastructure module

variable "gcp_account_json" {
  type        = string
  description = "File path and name of service account access token file."
}

variable "gcp_project" {
  type        = string
  description = "GCP project in which the quickstart will be deployed."
}

variable "gcp_region" {
  type        = string
  description = "GCP region used for all resources."
  default     = "asia-south1"
}

variable "gcp_zone" {
  type        = string
  description = "GCP zone used for all resources."
  default     = "asia-south1-c"
}

variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "qs"
}

variable "machine_type" {
  type        = string
  description = "Machine type used for all compute instances"
#  default     = "n1-standard-2"
  default     = "e2-medium" 
}

# Local variables used to reduce repetition
locals {
  node_username = "gcpuser"
}