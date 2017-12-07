provider "softlayer" {
  username = "${var.username}"
  api_key  = "${var.api_key}"
}

# This will create a new SSH key that will show up under the Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "amazon_key_1" {
  label = "${var.prefix}_ctspkey"
  public_key = "${file("${var.public_key_path}")}"
}

#EE
resource "softlayer_virtual_guest" "MSctspEE" {
  hostname             = "${var.prefix}${var.ee_hostname}"
  private_network_only = true
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${softlayer_ssh_key.amazon_key_1.id}"]
  domain               = "${var.domain}"
  image_id             = "${var.tools_image_id}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  local_disk           = "${var.local_disk}"
  provisioner "remote-exec" {
    connection {
      type    = "ssh"
      user    = "root"
      port    = 22
      private_key = "${file("${var.private_key_path}")}"
    }
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose",
    ]
  }
}

#CHEF
resource "softlayer_virtual_guest" "MSctspCHEF" {
  hostname             = "${var.prefix}${var.chef_hostname}"
  private_network_only = true
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${softlayer_ssh_key.amazon_key_1.id}"]
  domain               = "${var.domain}"
  image_id             = "${var.tools_image_id}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  local_disk           = "${var.local_disk}"
  provisioner "remote-exec" {
    connection {
      type    = "ssh"
      user    = "root"
      port    = 22
      private_key = "${file("${var.private_key_path}")}"
    }
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose",

    ]
  }
}

#BPM
resource "softlayer_virtual_guest" "MSctspBPM" {
  hostname             = "${var.prefix}${var.bpm_hostname}"
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_network_only = true
  image_id             = "${var.tools_image_id}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${softlayer_ssh_key.amazon_key_1.id}"]
  domain               = "${var.domain}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  provisioner "remote-exec" {
    connection {
      type    = "ssh"
      user    = "root"
      port    = 22
      private_key = "${file("${var.private_key_path}")}"
    }
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose"

    ]
  }
}

#FIREWALL
resource "softlayer_virtual_guest" "MSctspFW" {
  hostname             = "${var.prefix}${var.fw_hostname}"
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${softlayer_ssh_key.amazon_key_1.id}"]
  image_id             = "${var.fw_image_id}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  domain               = "${var.domain}"
  hourly_billing       = "${var.hourly_billing}"
  disks                = "${var.disks}"
  local_disk           = true
  provisioner "remote-exec" {
    connection {
      type    = "ssh"
      user    = "root"
      port    = 2222
      private_key = "${file("${var.private_key_path}")}"
      host    = "${softlayer_virtual_guest.MSctspFW.ipv4_address_private}"
    }
    inline = ["echo 'hello World' > hi.txt"]
  }
}

output "BPM_Instructions"  {
  value = "Use `ssh -i /Users/path/yourPrivateKey.pem root@[svg_bpm_ipv4]` to ssh in"
}

output "svg_bpm_ipv4_address_private"  {
  value = "${softlayer_virtual_guest.MSctspBPM.ipv4_address_private}"
}

output "CHEF_Instructions"  {
  value = "Use `ssh -i /Users/path/yourPrivateKey.pem root@[svg_rcp_ipv4]` to ssh in"
}

output "svg_chef_ipv4_address_private"  {
  value = "${softlayer_virtual_guest.MSctspCHEF.ipv4_address_private}"
}

output "FW_Instructions"  {
  value = "Use `ssh -i /Users/path/yourPrivateKey.pem root@[svg_fw_ipv4]` to ssh in"
}

output "svg_fw_ip_address_id"  {
  value = "${softlayer_virtual_guest.MSctspFW.ip_address_id}"
}

output "svg_fw_ipv6"  {
  value = "${softlayer_virtual_guest.MSctspFW.ipv6_address}"
}

output "svg_fw_ipv4"  {
  value = "${softlayer_virtual_guest.MSctspFW.ipv4_address}"
}

output "svg_fw_ipv4_address_private"  {
  value = "${softlayer_virtual_guest.MSctspFW.ipv4_address_private}"
}


