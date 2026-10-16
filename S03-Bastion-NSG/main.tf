resource "azurerm_network_security_group" "this" {
  tags                = var.tags
  resource_group_name = var.resource_group_name
  name                = var.nsg_name
  location            = var.location

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    protocol                   = "Tcp"
    priority                   = 1000
    name                       = "AzureBastionInBound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    description                = "Port 443 enabled on the public IP for ingress traffic"
    access                     = "Allow"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    protocol                   = "Tcp"
    priority                   = 1001
    name                       = "AzureBastionControlInBound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    description                = "Gateway Manager control plane communication to Azure Bastion"
    access                     = "Allow"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    protocol                   = "Tcp"
    priority                   = 1002
    name                       = "AzureBastionHostCommunicationInbound"
    direction                  = "Inbound"
    destination_address_prefix = "VirtualNetwork"
    description                = "Data plane communication of Azure Bastion"
    access                     = "Allow"

    destination_port_ranges = [
      "5701",
      "8080",
    ]
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    protocol                   = "Tcp"
    priority                   = 1003
    name                       = "AzureLoadBalancerInbound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    description                = "Enable port 443 inbound from the AzureLoadBalancer service tag"
    access                     = "Allow"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "*"
    protocol                   = "*"
    priority                   = 4096
    name                       = "Default_Deny_InBound_Override"
    direction                  = "Inbound"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    description                = "Required to override default rule AllowVnetInBound"
    access                     = "Deny"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "*"
    protocol                   = "Tcp"
    priority                   = 1000
    name                       = "AzureBastionOutBound"
    direction                  = "Outbound"
    destination_address_prefix = "VirtualNetwork"
    description                = "Allow egress traffic to target VMs"
    access                     = "Allow"

    destination_port_ranges = [
      "22",
      "3389",
    ]
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "*"
    protocol                   = "Tcp"
    priority                   = 1001
    name                       = "AzureBastionAzureCloudOutBound"
    direction                  = "Outbound"
    destination_port_range     = "443"
    destination_address_prefix = "AzureCloud"
    description                = "Azure Bastion needs outbound to 443 to AzureCloud service tag"
    access                     = "Allow"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    protocol                   = "Tcp"
    priority                   = 1002
    name                       = "AzureBastionHostCommunicationOutBound"
    direction                  = "Outbound"
    destination_address_prefix = "VirtualNetwork"
    description                = "Data plane communication of Azure Bastion"
    access                     = "Allow"

    destination_port_ranges = [
      "5701",
      "8080",
    ]
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "*"
    protocol                   = "Tcp"
    priority                   = 1003
    name                       = "AzureBastionGetSessionInformationOutBound"
    direction                  = "Outbound"
    destination_port_range     = "80"
    destination_address_prefix = "Internet"
    description                = "Azure Bastion communicates with the Internet for session and certificate validation"
    access                     = "Allow"
  }

  security_rule {
    source_port_range          = "*"
    source_address_prefix      = "*"
    protocol                   = "*"
    priority                   = 4096
    name                       = "Default_Deny_OutBound_Override"
    direction                  = "Outbound"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    description                = "Required to override default rules 65000"
    access                     = "Deny"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = var.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.this.id
  count                     = var.create_association ? 1 : 0
}

