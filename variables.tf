variable "aws_region" {
  default     = "us-east-2"
  description = "The region where resources will be deployed"
}

variable "cognito_callback_urls" {
  type        = list
  description = "Cognito Callback URLS"
}

variable "cognito_logout_urls" {
  type        = list
  description = "Cognito Logout URLS"
}

# Azure Subscription Id
variable "azure-subscription-id" {
  type        = string
  description = "Azure Subscription Id"
}
# Azure Client Id/appId
variable "azure-client-id" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Client Id/appId
variable "azure-client-secret" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Tenant Id
variable "azure-tenant-id" {
  type        = string
  description = "Azure Tenant Id"
}