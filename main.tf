# cria o provedor do azure responsável pelo gerenciamento dos recursos azure
# a versão é especificada para restringir qual a versão de provedor o terraform irá trabalhar
provider "azurerm" {
    version = "=1.27.0"
}

# cria um grupo de recursos na infraestrutura 
# o azurerm indica ao terraform que o recurso é gerenciado pelo provedor do azure
resource "azurerm_resource_group" "rg" {
    name        = "${var.prefix}TFResourceGroup"
    location    = "${var.location}"
    tags        = "${var.tags}"
}

# cria um grupo de recursos de vnet
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.prefix}TFVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    tags                = "${var.tags}"
}

# cria a subnet do ambiente
resource "azurerm_subnet" "subnet" {
    name                    = "${var.prefix}TFSubnet"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
    address_prefix          = "10.0.1.0/24"
}

# cria IP publico para o ambiente
resource "azurerm_public_ip" "publicip" {
    name                            = "${var.prefix}TFPublicIP"
    location                        = "${var.location}"
    resource_group_name             = "${azurerm_resource_group.rg.name}"
    #public_ip_address_allocation    = "dynamic"
    allocation_method               = "Static"
    tags                            = "${var.tags}"
}

# cria as regras de Network Secuirty Group e suas regras
resource "azurerm_network_security_group" "nsg" {
    name                  = "${var.prefix}TFNSG"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    tags                  = "${var.tags}"

    security_rule {
        name                          = "SSH"
        priority                      = 1001
        direction                     = "Inbound"
        access                        = "Allow"
        protocol                      = "Tcp"
        source_port_range             = "*"
        destination_port_range        = "22"
        source_address_prefix         = "*"
        destination_address_prefix    = "*"
    }
}

# cria a interface de rede
resource "azurerm_network_interface" "nic" {
    name                        = "${var.prefix}NIC"
    location                    = "${var.location}"
    resource_group_name         = "${azurerm_resource_group.rg.name}"
    network_security_group_id   = "${azurerm_network_security_group.nsg.id}"
    tags                        = "${var.tags}"

    ip_configuration {
        name                            = "${var.prefix}NICConfg"
        subnet_id                       = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation   = "dynamic"
        public_ip_address_id            = "${azurerm_public_ip.publicip.id}"
    }
}

# cria a máquina virtual linuz (ubuntu)
resource "azurerm_virtual_machine" "vm" {
    name                    = "${var.prefix}TFVM"  
    location                = "${var.location}"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    network_interface_ids   = ["${azurerm_network_interface.nic.id}"]
    #vm_size                 = "Standard_DS1_v2"
    vm_size                 = "${var.vm_size}"
    tags                    = "${var.tags}"

  storage_os_disk {
      name              = "${var.prefix}OsDisk"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
      publisher = "${var.publi}"
      offer     = "${var.os_dist}"
      sku       = "${lookup(var.sku, var.location)}"
      version   = "latest"
  }

  os_profile {
      computer_name     = "${var.prefix}TFVM"
      admin_username    = "garibaldi"
      admin_password    = "Abc123d4$"
  }

  os_profile_linux_config {
      disable_password_authentication = false
  }
}