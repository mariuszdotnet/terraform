existing_subnet_resoruce_id = "/subscriptions/5aec60e9-f535-4bd7-a951-2833f043e918/resourceGroups/packer-rg/providers/Microsoft.Network/virtualNetworks/packer-rg-vnet/Subnets/default"

image_name = "WindowsServer2016DC-1"

image_resource_group = "packer-image-repo-rg"

location = "east us 2"

resource_group_name = "terraform3-rg"

cost_center_tag = "123456789"

# <= 15 charaters
computer_name = "AZWAPPRD3"

vm_size = "Standard_DS1_v2" 

data_disk_size = "512"