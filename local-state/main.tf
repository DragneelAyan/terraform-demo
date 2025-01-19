# Specify the provider
provider "azurerm" {
  features {} #Required block for AzureRM provider
}

# Configure local backend for state storage
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}


# Define a resource group
resource "azurerm_resource_group" "rg" {
  name = "linux-vm-rg"
  location = "Central Asia"
}

# Define a virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "linux-vm-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = [ "10.0.0.0/16" ]
}

# Define a subnet
resource "azurerm_subnet" "subnet" {
  name = "linux-vm-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

# Define a network inteface
resource "azurerm_network_interface" "nic" {
  name = "linux-vm-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define a Linux virtual machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name = "linux-vm"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_B1ls"
  admin_username = "azureuser"
  admin_password = "Password@1234"
  network_interface_ids = [ azurerm_network_interface.nic.id ]
  disable_password_authentication = false

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
}