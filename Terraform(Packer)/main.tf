data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

data "azurerm_image" "custom" {
  name                = "iac-custom-ubuntu-image"
  resource_group_name = "packer-image-rg"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "packer-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags     = local.tags
}

resource "azurerm_subnet" "sub" {
  name                 = "packer-default-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "packer-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags     = local.tags

  security_rule {
    name                       = "AllowInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "packer-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags     = local.tags
}

resource "azurerm_lb" "load" {
  name                = "packer-lb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  tags     = local.tags
}

resource "azurerm_availability_set" "set" {
  name                         = "packer-av-set"
  location                     = var.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags     = local.tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "packer-nic-${count.index}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }

  tags     = local.tags
  }

  resource "azurerm_lb_backend_address_pool" "main" {
  name                = "packer-backend-pool"
  loadbalancer_id     = azurerm_lb.load.id

}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "packer-vm-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "babafunbi1"
  availability_set_id = azurerm_availability_set.set.id
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_ssh_key {
    username   = "babafunbi1"
    public_key = file(var.ssh_public_key)
  }

  source_image_id = data.azurerm_image.custom.id
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-${count.index}"
  }

  tags     = local.tags
}
