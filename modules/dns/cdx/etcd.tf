data "template_file" "scripts_generate_nsupdate" {
  template = <<EOF
#!/bin/bash

ips="$${private_ip_addresses}"
nodes="$${etcd_node_names}"

n="$${#nodes[*]}"

nsupdate_cmds=$(cat <<END
update delete $${cluster_name}-etcd.$${base_domain} A
update add $${cluster_name}-etcd.$${base_domain} 0 A $${etcd_lb_ip_address}
END
)

for ((i=0; i<$n; i++)); do
  nsupdate_cmds="$nsupdate_cmds
  update delete $${node[$i]} A
  update add $${nodes[$i]} 0 A $${ips[$i]}"
done

echo "$nsupdate_cmds" > $${nsupdate_path}
echo -e "\nsend" >> $${nsupdate_path}
EOF

  vars {
    nsupdate_path = "${path.cwd}/generated/dns/etcd-dns.txt"
    cluster_name  = "${var.cluster_name}"
    base_domain   = "${var.base_domain}"

    etcd_lb_ip_address = "${var.etcd_lb_ip_address}"
    private_ip_addresses     = "${join(" ", var.etcd_ip_addresses)}"
    etcd_node_names = "${join(" ", var.etcd_node_names)}"
  }
}

resource "local_file" "generate-nsupdate" {
  content  = "${data.template_file.scripts_generate_nsupdate.rendered}"
  filename = "${path.cwd}/generated/dns/generate-etcd-dns.sh"
}

resource "null_resource" "scripts_nsupdate" {
  depends_on = ["local_file.generate-nsupdate"]

  triggers {
    md5 = "${md5(data.template_file.scripts_generate_nsupdate.rendered)}"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/generated/dns/generate-etcd-dns.sh ; nsupdate -d ${path.cwd}/generated/dns/etcd-dns.txt"
  }
}
