resource "azurerm_network_security_group" "worker" {
  count               = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                = "${var.tectonic_cluster_name}-worker"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "worker-out" {
  count                       = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-OUT-worker-ANY-ANY-ANY"
  priority                    = 2010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-ssh" {
  count                       = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-worker-TCP-22-ssh-vnet"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_internal}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-ssh_admin" {
  count                       = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-worker-TCP-22-ssh-admin"
  priority                    = 605
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.ssh_network_external}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-flannel" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-UDP-4789-master"
  priority               = 620
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-flannel_from_master" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-UDP-4789-worker"
  priority               = 625
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "udp"
  source_port_range      = "*"
  destination_port_range = "4789"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-services" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-ANY-30000-32767-vnet"
  priority               = 610
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "30000-32767"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

#resource "azurerm_network_security_rule" "worker-in-services_from_console" {
#  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-worker-services_from_console"
#  priority               = 615
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "30000-32767"
#
#  # TODO: Need to allow traffic from console
#  source_address_prefix       = "VirtualNetwork"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

resource "azurerm_network_security_rule" "worker-in-kubelet_insecure" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-10250-master"
  priority               = 630
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "10250"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

#resource "azurerm_network_security_rule" "worker-in-kubelet_insecure_from_master" {
#  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-worker-kubelet_insecure_from_master"
#  priority               = 635
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "10250"
#
#  # TODO: Need to allow traffic from master
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

#resource "azurerm_network_security_rule" "worker-in-kubelet_secure" {
#  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-worker-kubelet_secure"
#  priority               = 640
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "10255"
#
#  # TODO: Need to allow traffic from self
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

#resource "azurerm_network_security_rule" "worker-in-kubelet_secure_from_master" {
#  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-worker-kubelet_secure_from_master"
#  priority               = 645
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "10255"
#
#  # TODO: Need to allow traffic from master
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

resource "azurerm_network_security_rule" "worker-in-node_exporter" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-9100-master"
  priority               = 650
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "worker-in-node_exporter_from_master" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-9100-worker"
  priority               = 655
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "9100"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

#resource "azurerm_network_security_rule" "worker-in-heapster" {
#  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                   = "${var.tectonic_cluster_name}-IN-worker-heapster"
#  priority               = 660
#  direction              = "Inbound"
#  access                 = "Allow"
#  protocol               = "tcp"
#  source_port_range      = "*"
#  destination_port_range = "4194"
#
#  # TODO: Need to allow traffic from self
#  source_address_prefix       = "${var.vnet_cidr_block}"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

resource "azurerm_network_security_rule" "worker-in-heapster_from_master" {
  count                  = "${var.external_nsg_worker == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-4194-master"
  priority               = 665
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "4194"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "master-in-etcd_lb" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-2379-2380-master"
  priority               = 540
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "master-in-etcd_self" {
  count                  = "${var.external_nsg_master == "" ? 1 : 0}"
  name                   = "${var.tectonic_cluster_name}-IN-worker-TCP-2379-2380-worker"
  priority               = 545
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "tcp"
  source_port_range      = "*"
  destination_port_range = "2379-2380"
  source_address_prefix       = "${var.vnet_cidr_block}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

resource "azurerm_network_security_rule" "alb_probe" {
  count                       = "${var.external_nsg_api == "" ? 1 : 0}"
  name                        = "${var.tectonic_cluster_name}-IN-worker-TCP-ANY-ALB"
  priority                    = 295
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
  network_security_group_name = "${azurerm_network_security_group.worker.name}"
}

#resource "azurerm_network_security_rule" "worker-in-http" {
#  count                       = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                        = "${var.tectonic_cluster_name}-IN-worker-http"
#  priority                    = 670
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "*"
#  destination_port_range      = "80"
#  source_address_prefix       = "VirtualNetwork"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}

#resource "azurerm_network_security_rule" "worker-in-https" {
#  count                       = "${var.external_nsg_worker == "" ? 1 : 0}"
#  name                        = "${var.tectonic_cluster_name}-IN-worker-https"
#  priority                    = 675
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "tcp"
#  source_port_range           = "*"
#  destination_port_range      = "443"
#  source_address_prefix       = "VirtualNetwork"
#  destination_address_prefix  = "*"
#  resource_group_name         = "${var.external_resource_group == "" ? var.resource_group_name : var.external_resource_group}"
#  network_security_group_name = "${azurerm_network_security_group.worker.name}"
#}
