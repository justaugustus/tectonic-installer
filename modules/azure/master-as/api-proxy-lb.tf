## Workaround for https://github.com/coreos/tectonic-installer/issues/657
## Related to: https://github.com/Microsoft/azure-docs/blob/master/articles/load-balancer/load-balancer-internal-overview.md#limitations

resource "azurerm_lb" "proxy_lb" {
  name                = "${var.cluster_name}-console-proxy-lb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "console-proxy"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "console-proxy-lb" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.proxy_lb.id}"
  name                = "console-proxy-lb-pool"
}

resource "azurerm_lb_rule" "console-proxy-lb" {
  name                    = "console-proxy-lb-rule-443-443"
  resource_group_name     = "${var.resource_group_name}"
  loadbalancer_id         = "${azurerm_lb.proxy_lb.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.console-proxy-lb.id}"
  probe_id                = "${azurerm_lb_probe.console-proxy-lb.id}"

  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "console-proxy"
}

resource "azurerm_lb_probe" "console-proxy-lb" {
  name                = "console-proxy-lb-probe-443-up"
  loadbalancer_id     = "${azurerm_lb.proxy_lb.id}"
  resource_group_name = "${var.resource_group_name}"
  protocol            = "tcp"
  port                = 443
}