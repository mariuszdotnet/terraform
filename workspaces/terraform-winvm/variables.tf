# Variables required for creating a stamp VM.

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

variable "cost_center_tag" {
  description = "The cost center for all resoruces created by this TF file"
}

variable "computer_name" {
  description = "The name used for the computer name and the host name of the vm"
}

variable "admin_username" {
  description = "The local admin user name"
  default = "adazadmin"
}

variable "vm_size" {
  description = "The vm size"
}

variable "managed_disk_type" {
  description = "Type of managed disk for os and storage disks"
  default = "Standard_LRS"
}

variable "data_disk_size" {
  description = "size of data disk/s to create"
  default = "1023"
}