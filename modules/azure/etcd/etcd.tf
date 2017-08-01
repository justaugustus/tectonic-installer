resource "azurerm_availability_set" "etcd" {
  count               = "${var.etcd_count > 0 ? 1 : 0}"
  name                = "${var.cluster_name}-etcd"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  managed             = true

  tags = "${merge(map(
    "Name", "${var.cluster_name}-etcd",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}

resource "azurerm_virtual_machine" "etcd_node" {
  count                 = "${var.etcd_count}"
  name                  = "${format("%s%s%03d", var.cluster_name, "e", count.index + 1)}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${var.network_interface_ids[count.index]}"]
  vm_size               = "${var.vm_size}"
  availability_set_id   = "${azurerm_availability_set.etcd.id}"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "${var.cl_channel}"
    version   = "${var.versions["container_linux"]}"
  }

  storage_os_disk {
    name              = "etcd-${count.index}-os-${var.storage_id}"
    managed_disk_type = "Premium_LRS"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    os_type           = "linux"
  }

  os_profile {
    computer_name  = "${format("%s%s%03d", var.cluster_name, "e", count.index + 1)}"
    admin_username = "core"
    admin_password = ""
    custom_data    = "${base64encode("${data.ignition_config.etcd.*.rendered[count.index]}")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/core/.ssh/authorized_keys"
      key_data = "${file(var.public_ssh_key)}"
    }
  }

  tags = "${merge(map(
    "Name", "${var.cluster_name}-etcd-${count.index}",
    "tectonicClusterID", "${var.cluster_id}"),
    var.extra_tags)}"
}
