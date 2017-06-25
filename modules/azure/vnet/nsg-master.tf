resource "azurerm_network_security_group" "master" {
  count               = "${var.external_nsg_master == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-master"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "master-out" {
  count                       = "${var.external_nsg_master == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-OUT-master-ANY-ANY-ANY"
  priority                    = 2005
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-ssh-vnet" {
  count                       = "${var.external_nsg_master == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-master-TCP-22-ssh-vnet"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-ssh-admin" {
  count                       = "${var.external_nsg_master == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-master-TCP-22-ssh-admin"
  priority                    = 505
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-flannel" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-UDP-4789-master"
  priority               = 510
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-flannel_from_worker" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-UDP-4789-worker"
  priority               = 515
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-node_exporter" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-9100-master"
  priority               = 520
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-node_exporter_from_worker" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-9100-worker"
  priority               = 525
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-services" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-ANY-30000-32767-vnet"
  priority               = 530
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

#resource "azurerm_network_security_rule" "master-in-services_from_console" {
#  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-master-services_from_console"
#  priority               = 535
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "30000-32767"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.master.name}"
#}

resource "azurerm_network_security_rule" "master-in-bootstrap_etcd" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-12379-12380-master"
  priority               = 550
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "12379-12380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-etcd_lb" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-2379-2380-master"
  priority               = 540
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-etcd_self" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-2379-2380-worker"
  priority               = 545
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379-2380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

#resource "azurerm_network_security_rule" "master-in-kubelet_insecure" {
#  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-master-kubelet_insecure"
#  priority               = 555
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "10250"
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.master.name}"
#}

#resource "azurerm_network_security_rule" "master-in-kubelet_insecure_from_worker" {
#  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-master-kubelet_insecure_from_worker"
#  priority               = 560
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "10250"
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.master.name}"
#}

resource "azurerm_network_security_rule" "master-in-kubelet_secure" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-10255-master"
  priority               = 565
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-kubelet_secure_from_worker" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-master-TCP-10255-worker"
  priority               = 570
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10255"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "alb_probe" {
  count                       = "${var.external_nsg_api == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-master-TCP-ANY-ALB"
  priority                    = 295
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-https" {
  count                       = "${var.external_nsg_master == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-LB-TCP-443-ANY"
  priority                    = 580
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

resource "azurerm_network_security_rule" "master-in-http" {
  count                       = "${var.external_nsg_master == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-LB-TCP-80-ANY"
  priority                    = 575
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.master.name}"
}

#resource "azurerm_network_security_rule" "master-in-heapster" {
#  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-master-heapster"
#  priority               = 585
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "4194"
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.master.name}"
#}

#resource "azurerm_network_security_rule" "master-in-heapster_from_worker" {
#  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-master-heapster_from_worker"
#  priority               = 590
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "4194"
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.master.name}"
#}
