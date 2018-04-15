#
# WoW I can have comments : )
#
variable "subscription_id" {
  description = "The subscription ID for the deployment"
}

variable "client_id" {
  description = "Registered App Client ID"
}

variable "client_secret" {
  description = "The Secret"
}

variable "tenant_id" {
  description = "The Azure AD Tenant ID for the Client ID"
}

variable "azure_tf_provider_version" {
  description = "The version of the Azure TF provider to use"
  default     = 1.3
}

variable "existing_subnet_resoruce_id" {
  description = "The resoruce ID of the subnet for the VM to attached the NIC"
}

variable "location" {
  description = "The location where the Resources will be provisioned. This needs to be the same as where the Image exists."
}

variable "resource_group_name" {
  description = "The  resource group to deploy the VM into."
}

variable "image_name" {
  description = "The name of the existing Golden Image"
}

variable "image_resource_group" {
  description = "The name of the Resource Group where the Golden Image is located."
}
