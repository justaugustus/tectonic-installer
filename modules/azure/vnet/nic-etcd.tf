resource "azurerm_network_interface" "etcd_nic" {
  count                     = "${var.etcd_count}"
  name                      = "${var.cluster_name}-etcd-nic-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${var.external_nsg_etcd_id == "" ? azurerm_network_security_group.etcd.id : var.external_nsg_etcd_id}"

  ip_configuration {
    name                                    = "tectonic_etcd_configuration"
    subnet_id                               = "${var.external_master_subnet_id == "" ? join(" ", azurerm_subnet.master_subnet.*.id) : var.external_master_subnet_id }"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.etcd-lb.id}"]
  }
}
