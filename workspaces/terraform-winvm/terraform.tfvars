# The subnet ID where to plance the VM (Must be same location as VM)
existing_subnet_resoruce_id = "/subscriptions/5aec60e9-f535-4bd7-a951-2833f043e918/resourceGroups/packer-rg/providers/Microsoft.Network/virtualNetworks/packer-rg-vnet/Subnets/default"

# Name of the resource group where for the image
image_resource_group = "shared-image-gallery-rg"

# Location for the VM
location = "Canada Central"

# Name of the resource group for the VM
resource_group_name = "terraform-windows-rg"

# Required Tags
tags = {
  CostCenter = "123"
  UseCase    = "Test Server 1"
}

# <= 15 charaters
computer_name = "test-windows-vm"

# Supported VM Family Sizes: Standard_F1s, Standard_E2s_v3, Standard_E4s_v3, Standard_E8s_v3, Standard_E16s_v3

vm_size = "Standard_DS1_v2"

# Supported Disk Sizes: 32 GiB,64 GiB, 128 GiB,256 GiB,512 GiB,1024 GiB (1 TiB),2048 GiB (2 TiB),4095 GiB (4 TiB)
data_disk_size = "32"

# Details of the image from Azure SIG
sig_image_version       = "1.0.0"
sig_image_name          = "myWindowsDefinition"
sig_gallery_name        = "myGallery"
sig_resource_group_name = "shared-image-gallery-rg"