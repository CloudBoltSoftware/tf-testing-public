resource "random_pet" "resource_prefix" {
}

resource "random_id" "resource_id" {
  keepers = {
    pet_id = random_pet.resource_prefix.id
  }

  byte_length = 8
}

locals {
  prefix = "${random_pet.resource_prefix.id}_${random_id.resource_id.id}"
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_location
  name     = "${local.prefix}_rg"
}

# Create virtual network
resource "azurerm_virtual_network" "network" {
  name                = "${local.prefix}_vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "${local.prefix}_ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.environment
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "security_group" {
  name                = "${local.prefix}_sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.prefix}_sn"
  virtual_network_name = azurerm_virtual_network.network.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${local.prefix}_nc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.prefix}_ic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = var.environment
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage_account" {
  name                     = "${random_id.resource_id.dec}sa"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = {
    name = "${local.prefix}_sa"
    environment = var.environment
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  depends_on = [azurerm_network_interface.nic, azurerm_network_interface_security_group_association.sg_assoc]

  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Basic_A0"

  os_disk {
    name                 = "${local.prefix}_os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "${random_pet.resource_prefix.id}-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  }

  tags = {
    environment = var.environment
  }
}