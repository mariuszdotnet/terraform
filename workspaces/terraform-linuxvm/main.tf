# Azure provider configuration section
provider "azurerm" {
  version = "~> 1.23"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Reference Azure SIG image
data "azurerm_shared_image_version" "vmstamp" {
  name                = "${var.sig_image_version}"
  image_name          = "${var.sig_image_name}"
  gallery_name        = "${var.sig_gallery_name}"
  resource_group_name = "${var.sig_resource_group_name}"
}

# Create the resoruce group for the vm
resource "azurerm_resource_group" "vmstamp" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = "${var.tags}"
}

#Create the public IP for the vm
resource "azurerm_public_ip" "vmstamp" {
  name                = "ip-${var.computer_name}-2"
  location            = "${azurerm_resource_group.vmstamp.location}"
  resource_group_name = "${azurerm_resource_group.vmstamp.name}"
  allocation_method   = "Dynamic"

  tags = "${var.tags}"
}

# Create the NIC for the vm
resource "azurerm_network_interface" "vmstamp" {
  name                = "nic-${var.computer_name}-1"
  location            = "${azurerm_resource_group.vmstamp.location}"
  resource_group_name = "${azurerm_resource_group.vmstamp.name}"
  tags = "${var.tags}"

  ip_configuration {
    name                          = "ip-${var.computer_name}-1"
    subnet_id                     = "${var.existing_subnet_resoruce_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.vmstamp.id}"
  }
}

# Generate random password for local admin pass
resource "random_string" "vmstamp" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = true
}

# Create the vm
resource "azurerm_virtual_machine" "vmstamp" {
  name                  = "${var.computer_name}"
  location              = "${azurerm_resource_group.vmstamp.location}"
  resource_group_name   = "${azurerm_resource_group.vmstamp.name}"
  network_interface_ids = ["${azurerm_network_interface.vmstamp.id}"]
  vm_size               = "${var.vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_shared_image_version.vmstamp.id}"
  }
  storage_os_disk {
    name              = "disk-${var.computer_name}-os1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.managed_disk_type}"
    disk_size_gb      = 128
  }
  os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${random_string.vmstamp.result}"
  }
  os_profile_linux_config = {
    disable_password_authentication = false
  }
  tags = "${var.tags}"
  # Data disks
  storage_data_disk {
    name              = "disk-${var.computer_name}-data1"
    managed_disk_type = "${var.managed_disk_type}"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.data_disk_size}"
  }
}

# Azure ARM template to make the IP static after it's provisioned as dynamic by TF
resource "azurerm_template_deployment" "vmstamp" {
  depends_on          = ["azurerm_network_interface.vmstamp"]
  name                = "${var.computer_name}-temptemplate-01"
  resource_group_name = "${azurerm_resource_group.vmstamp.name}"

  template_body = <<DEPLOY
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "nicName":{
            "type": "string",
            "metadata": {
                "description": "Name of the nic."
            }
        },
        "privavmstampaticIpConfig":{
            "type": "string",
            "metadata": {
                "description": "Name of the privavmstampaticIpConfig."
            }
        },
        "existingSubnetId":{
            "type": "string",
            "metadata": {
                "description": "Resource Id of the existing subnet."
            }
        },
        "ipAddress":{
            "type": "string",
            "metadata": {
                "description": "IP address to be set static."
            }
        }
    },
    "resources": [
    {
        "type": "Microsoft.Network/networkInterfaces",
        "name": "[parameters('nicName')]",
        "apiVersion": "2017-10-01",
        "location": "[resourceGroup().location]",
        "properties": {
            "ipConfigurations": [
                {
                    "name": "[parameters('privavmstampaticIpConfig')]",
                    "properties": {
                        "privateIPAllocationMethod": "Static",
                        "privateIPAddress": "[parameters('ipAddress')]",
                        "subnet": {
                            "id": "[parameters('existingSubnetId')]"
                          }
                    }
                }
            ]
        }
    }]
  }
  DEPLOY

  deployment_mode = "Incremental"

  parameters {
    "nicName"                  = "${azurerm_network_interface.vmstamp.name}"
    "privavmstampaticIpConfig" = "${azurerm_network_interface.vmstamp.ip_configuration.0.name}"
    "ipAddress"                = "${azurerm_network_interface.vmstamp.private_ip_address}"
    "existingSubnetId"         = "${var.existing_subnet_resoruce_id}"
  }
}
