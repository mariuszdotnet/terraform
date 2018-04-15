provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  version         = "1.3"
}

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "${var.image_name}"
  resource_group_name = "${var.image_resource_group}"
}

output "image_id" {
  value = "${data.azurerm_image.search.id}"
}

resource "azurerm_resource_group" "test" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "test" {
  name                = "acctni"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${var.existing_subnet_resoruce_id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "test" {
  name                 = "datadisk_existing"
  location             = "${azurerm_resource_group.test.location}"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  # Optional data disks
  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }
  storage_data_disk {
    name            = "${azurerm_managed_disk.test.name}"
    managed_disk_id = "${azurerm_managed_disk.test.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.test.disk_size_gb}"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config = {}
  tags {
    environment = "staging"
  }
}

resource "azurerm_template_deployment" "test" {
  depends_on          = ["azurerm_network_interface.test"]
  name                = "acctesttemplate-01"
  resource_group_name = "${azurerm_resource_group.test.name}"

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
        "privateStaticIpConfig":{
            "type": "string",
            "metadata": {
                "description": "Name of the privateStaticIpConfig."
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
                    "name": "[parameters('privateStaticIpConfig')]",
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
    "nicName"               = "${azurerm_network_interface.test.name}"
    "privateStaticIpConfig" = "${azurerm_network_interface.test.ip_configuration.0.name}"
    "ipAddress"             = "${azurerm_network_interface.test.private_ip_address}"
    "existingSubnetId"      = "${var.existing_subnet_resoruce_id}"
  }
}
