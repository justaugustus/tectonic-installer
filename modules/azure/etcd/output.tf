output "node_names" {
  # UPSTREAM
  #value = ["${compact(split(";", var.base_domain == "" ?
  #  join(";", slice(formatlist("${var.cluster_name}-%s", var.const_internal_node_names), 0, var.etcd_count)) :
  #  join(";", formatlist("%s.${var.base_domain}", slice(formatlist("${var.cluster_name}-%s", var.const_internal_node_names), 0, var.etcd_count)))))
  #}"]
  value = ["${compact(split(";", var.base_domain == "" ?
    join(";", slice(formatlist("${var.cluster_name}%s", var.const_internal_node_names), 0, var.etcd_count)) :
    join(";", formatlist("%s.${var.base_domain}", slice(formatlist("${var.cluster_name}%s", var.const_internal_node_names), 0, var.etcd_count)))))
  }"]
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_1_name" {
  value = "${format("%s%s%03d", var.cluster_name, "e", 1)}"
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_2_name" {
  value = "${format("%s%s%03d", var.cluster_name, "e", 2)}"
}

# TODO: Remove hardcoded etcd values. This is a workaround for DNS + TLS.
output "etcd_node_3_name" {
  value = "${format("%s%s%03d", var.cluster_name, "e", 3)}"
}
