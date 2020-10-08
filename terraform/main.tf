provider "azurerm" {
    version = "~>2.30"
    features {}
}

resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.resource_group_name}"
    location =  "${var.location}"
    tags = "${var.tags}"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    tags = "${var.tags}"
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

# **********************
# Public IP Resource Creation
# **********************

resource "azurerm_public_ip" "myterraformpublicip" {
    count                        = 3
    name                         = "myPublicIP-${count.index}"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"
    tags                         =   "${var.tags}"

}


# **********************
# NSG Resource Creation
# **********************

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

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
     tags = "${var.tags}"
}

# **********************
# NIC Resource Creation
# **********************

resource "azurerm_network_interface" "myterraformnic" {
     count                      = 3
    name                        = "myNIC-${count.index}"
    location                    = "${var.location}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "myNicConfiguration-${count.index}"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
       # public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
       public_ip_address_id = "${length(azurerm_public_ip.myterraformpublicip.*.id) > 0 ? element(concat(azurerm_public_ip.myterraformpublicip.*.id, list("")), count.index) : ""}"
    }
      tags = "${var.tags}"
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    count                     = 3
    network_interface_id      = azurerm_network_interface.myterraformnic[count.index].id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}
   


resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "${var.location}"
    account_replication_type    = "LRS"
    account_tier                = "Standard"
    tags = "${var.tags}"
}


resource "azurerm_linux_virtual_machine" "myterraformvm" {
    count                 = 3
    name                  = "${var.vm_hostname}-${count.index}"
    location              = "${var.location}"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id, count.index)}"]
    size                  = "${var.vm_size}"    

    os_disk {
        name              = "myOsDisk${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "${var.storage_account_type}"
    }

    source_image_reference {
        publisher = "${var.vm_os_publisher}"
        offer     = "${var.vm_os_offer}"
        sku       = "${var.vm_os_sku}"
        version   = "${var.vm_os_version}"
    }
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = "${var.admin_username}"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "${var.admin_username}"
        public_key     = "${file("${var.ssh_key}")}"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
    tags = "${var.tags}"
}
