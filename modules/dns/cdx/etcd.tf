data "template_file" "scripts_nsupdate_etcd" {
  template = <<EOF
#!/bin/bash

ips="$${private_ip_addresses}"

nsupdate_cmds=$(cat <<END
update delete $${etcd_node_1_name}.$${base_domain} A
update add $${etcd_node_1_name}.$${base_domain} 0 A $${etcd_node_1_ip}
update delete $${etcd_node_2_name}.$${base_domain} A
update add $${etcd_node_2_name}.$${base_domain} 0 A $${etcd_node_2_ip}
update delete $${etcd_node_3_name}.$${base_domain} A
update add $${etcd_node_3_name}.$${base_domain} 0 A $${etcd_node_3_ip}
END
)

echo "$nsupdate_cmds" > $${nsupdate_path}
echo -e "\nsend" >> $${nsupdate_path}
EOF

  vars {
    nsupdate_path = "${path.cwd}/generated/dns/etcd-dns.txt"
    cluster_name  = "${var.cluster_name}"
    base_domain   = "${var.base_domain}"

    private_ip_addresses = "${join(" ", var.etcd_ip_addresses)}"
    etcd_node_names      = "${join(" ", var.etcd_node_names)}"
    etcd_node_1_name     = "${var.etcd_node_1_name}"
    etcd_node_2_name     = "${var.etcd_node_2_name}"
    etcd_node_3_name     = "${var.etcd_node_3_name}"
    etcd_node_1_ip       = "${var.etcd_node_1_ip}"
    etcd_node_2_ip       = "${var.etcd_node_2_ip}"
    etcd_node_3_ip       = "${var.etcd_node_3_ip}"
  }
}

resource "local_file" "generate_nsupdate_etcd" {
  content  = "${data.template_file.scripts_nsupdate_etcd.rendered}"
  filename = "${path.cwd}/generated/dns/generate-etcd-dns.sh"
}

resource "null_resource" "scripts_nsupdate_etcd" {
  depends_on = ["local_file.generate_nsupdate_etcd"]

  triggers {
    md5 = "${md5(data.template_file.scripts_nsupdate_etcd.rendered)}"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/generated/dns/generate-etcd-dns.sh ; nsupdate -d ${path.cwd}/generated/dns/etcd-dns.txt"
  }
}