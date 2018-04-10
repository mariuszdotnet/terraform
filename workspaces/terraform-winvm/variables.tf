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
