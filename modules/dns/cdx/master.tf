data "template_file" "scripts_nsupdate_master" {
  template = <<EOF
#!/bin/bash

ips="$${private_ip_addresses}"

nsupdate_cmds=$(cat <<END
update delete $${cluster_name}.$${base_domain} A
update add $${cluster_name}.$${base_domain} 0 A $${console_proxy_ip_address}
update delete $${cluster_name}-master.$${base_domain} A
update add $${cluster_name}-master.$${base_domain} 0 A $${ip_address}
update delete $${cluster_name}-api.$${base_domain} A
END
)

for i in $ips
do
    nsupdate_cmds="$nsupdate_cmds
update add $${cluster_name}-api.$${base_domain} 0 A $i"
done

echo "$nsupdate_cmds" > $${nsupdate_path}
echo -e "\nsend" >> $${nsupdate_path}
EOF

  vars {
    nsupdate_path = "${path.cwd}/generated/dns/k8s-dns.txt"
    cluster_name  = "${var.cluster_name}"
    base_domain   = "${var.base_domain}"

    ip_address               = "${var.api_private_ip}"
    private_ip_addresses     = "${join(" ", var.master_ip_addresses)}"
    console_proxy_ip_address = "${var.console_proxy_private_ip}"
  }
}

resource "local_file" "generate_nsupdate_master" {
  content  = "${data.template_file.scripts_nsupdate_master.rendered}"
  filename = "${path.cwd}/generated/dns/generate-k8s-dns.sh"
}

resource "null_resource" "scripts_nsupdate_master" {
  depends_on = ["local_file.generate_nsupdate_master"]

  triggers {
    md5 = "${md5(data.template_file.scripts_nsupdate_master.rendered)}"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/generated/dns/generate-k8s-dns.sh ; nsupdate -d ${path.cwd}/generated/dns/k8s-dns.txt"
  }
}
