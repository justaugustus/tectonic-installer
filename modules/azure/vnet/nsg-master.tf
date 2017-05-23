resource "azurerm_network_security_group" "master" {
  name                = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
  location            = "${var.tectonic_azure_location}"
  resource_group_name = "tectonic-cluster-${var.tectonic_cluster_name}"
}

resource "azurerm_network_security_rule" "master_egress" {
  name                        = "${var.tectonic_cluster_name}-master_egress"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

resource "azurerm_network_security_rule" "master_ingress_icmp" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_icmp"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}

resource "azurerm_network_security_rule" "master_ingress_ssh" {
  name                        = "${var.tectonic_cluster_name}-master_ingress_ssh"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "22"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "tectonic-cluster-${var.tectonic_cluster_name}"
  network_security_group_name = "tectonic-cluster-${var.tectonic_cluster_name}-master-nsg"
}
