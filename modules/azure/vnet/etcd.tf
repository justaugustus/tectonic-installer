resource "azurerm_network_interface" "etcd_nic" {
  count                     = "${var.etcd_count}"
  name                      = "${var.tectonic_cluster_name}-etcd-nic-${count.index}"
  location                  = "${var.location}"
  network_security_group_id = "${azurerm_network_security_group.etcd_group.id}"
  resource_group_name       = "${var.resource_group_name}"

  ip_configuration {
    name                                    = "tectonic_etcd_configuration"
    subnet_id                               = "${var.external_vnet_name == "" ?  join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.etcd-lb.id}"]
  }
}

resource "azurerm_lb" "tectonic_etcd_lb" {
  name                = "${var.tectonic_cluster_name}-etcd-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name = "default"

    public_ip_address_id          = "${azurerm_public_ip.etcd_publicip.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_public_ip" "etcd_publicip" {
  name                         = "${var.tectonic_cluster_name}_etcd_publicip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.tectonic_cluster_name}-etcd"
}

resource "azurerm_lb_rule" "etcd-lb" {
  name                           = "${var.tectonic_cluster_name}-etcd-lb-rule-client"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.tectonic_etcd_lb.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.etcd-lb.id}"
  probe_id                       = "${azurerm_lb_probe.etcd-lb.id}"
  protocol                       = "tcp"
  frontend_port                  = 2379
  backend_port                   = 2379
  frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_probe" "etcd-lb" {
  name                = "${var.tectonic_cluster_name}-etcd-lb-probe"
  loadbalancer_id     = "${azurerm_lb.tectonic_etcd_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "Tcp"
  port                = 2379
}

resource "azurerm_lb_backend_address_pool" "etcd-lb" {
  name                = "${var.tectonic_cluster_name}-etcd-lb-pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.tectonic_etcd_lb.id}"
}
