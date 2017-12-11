#provider "softlayer" {
#  username = "${var.username}"
#  api_key  = "${var.api_key}"
#}
provider "ibm" {
}

# This will create a new SSH key that will show up under the Devices>Manage>SSH Keys in the SoftLayer console.
#resource "softlayer_ssh_key" "public_key" {
#  label = "${var.prefix}_ctspkey"
#  public_key = "${file("${var.public_key_path}")}"
#}
data "softlayer_ssh_key" "public_key" {
    label = "ctspkey"
}

#EE
resource "ibm_compute_vm_instance" "MSctspEE" {
  hostname             = "${var.prefix}${var.ee_hostname}"
  private_network_only = true
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${data.softlayer_ssh_key.public_key.id}"]
  domain               = "${var.domain}"
  image_id             = "${var.tools_image_id}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  local_disk           = "${var.local_disk}"
}

#CHEF
resource "ibm_compute_vm_instance" "MSctspCHEF" {
  hostname             = "${var.prefix}${var.chef_hostname}"
  private_network_only = true
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${data.softlayer_ssh_key.public_key.id}"]
  domain               = "${var.domain}"
  image_id             = "${var.tools_image_id}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  local_disk           = "${var.local_disk}"
}

#BPM
resource "ibm_compute_vm_instance" "MSctspBPM" {
  hostname             = "${var.prefix}${var.bpm_hostname}"
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_network_only = true
  image_id             = "${var.tools_image_id}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${data.softlayer_ssh_key.public_key.id}"]
  domain               = "${var.domain}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
}

#FIREWALL
resource "ibm_compute_vm_instance" "MSctspFW" {
  hostname             = "${var.prefix}${var.fw_hostname}"
  datacenter           = "${var.datacenter}"
  tags                 = "${var.tags}"
  private_subnet       = "${var.private_subnet}"
  ssh_key_ids          = ["${data.softlayer_ssh_key.public_key.id}"]
  image_id             = "${var.fw_image_id}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  domain               = "${var.domain}"
  hourly_billing       = "${var.hourly_billing}"
  disks                = "${var.disks}"
  local_disk           = true
}

resource "null_resource" "bpm_remote_exec" {
  connection {
    type    = "ssh"
    user    = "root"
    port    = 22
    host    = "${ibm_compute_vm_instance.MSctspBPM.ipv4_address_private}"
    private_key = "${file("${var.private_key_path}")}"
  }
  provisioner "file" {
    source = "scripts/sasauto_cds.sh"
    destination = "/tmp/sasauto_cds.sh"
  }
  provisioner "file" {
    source = "scripts/sshd_cmd_logger.sh"
    destination = "/tmp/sshd_cmd_logger.sh"
  }
  provisioner "file" {
    source = "scripts/automate_add.sh"
    destination = "/tmp/automate_add.sh"
  }
  provisioner "remote-exec" {
    inline = ["sudo yum -y remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose",
    "docker run -dit -p 8443:9080 ubuntu bash -c \"apt-get update;apt-get -y install python;python -m SimpleHTTPServer 9080\"",
    "mkdir -p /sla_deploy_backup/os_user",
    "cd /sla_deploy_backup/os_user",
    "mv /tmp/sasauto_cds.sh .",
    "mv /tmp/sshd_cmd_logger.sh .",
    "mv /tmp/automate_add.sh .",
    "chmod +x automate_add.sh sasauto_cds.sh sshd_cmd_logger.sh; ./automate_add.sh; ./sasauto_cds.sh",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /root/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/automate/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/sasauto/.ssh/authorized_keys"
    ]   
  }
}

resource "null_resource" "chef_remote_exec" {
  connection {
    type    = "ssh"
    user    = "root"
    port    = 22
    host    = "${ibm_compute_vm_instance.MSctspCHEF.ipv4_address_private}"
    private_key = "${file("${var.private_key_path}")}"
  }
  provisioner "file" {
    source = "scripts/sasauto_cds.sh"
    destination = "/tmp/sasauto_cds.sh"
  }
  provisioner "file" {
    source = "scripts/sshd_cmd_logger.sh"
    destination = "/tmp/sshd_cmd_logger.sh"
  }
  provisioner "file" {
    source = "scripts/automate_add.sh"
    destination = "/tmp/automate_add.sh"
  }
  provisioner "remote-exec" {
    inline = ["sudo yum -y remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose",
    "docker run -dit -p 443:9080 ubuntu bash -c \"apt-get update;apt-get -y install python;python -m SimpleHTTPServer 9080\"",
    "mkdir -p /sla_deploy_backup/os_user",
    "cd /sla_deploy_backup/os_user",
    "mv /tmp/sasauto_cds.sh .",
    "mv /tmp/sshd_cmd_logger.sh .",
    "mv /tmp/automate_add.sh .",
    "chmod +x automate_add.sh sasauto_cds.sh sshd_cmd_logger.sh; ./automate_add.sh; ./sasauto_cds.sh",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /root/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/automate/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/sasauto/.ssh/authorized_keys"
    ]   
  }
}

resource "null_resource" "ee_remote_exec" {
  connection {
    type    = "ssh"
    user    = "root"
    port    = 22
    host    = "${ibm_compute_vm_instance.MSctspEE.ipv4_address_private}"
    private_key = "${file("${var.private_key_path}")}"
  }
  provisioner "file" {
    source = "scripts/sasauto_cds.sh"
    destination = "/tmp/sasauto_cds.sh"
  }
  provisioner "file" {
    source = "scripts/sshd_cmd_logger.sh"
    destination = "/tmp/sshd_cmd_logger.sh"
  }
  provisioner "file" {
    source = "scripts/automate_add.sh"
    destination = "/tmp/automate_add.sh"
  }
  provisioner "remote-exec" {
    inline = ["sudo yum -y remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
    "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
    "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
    "subscription-manager repos --enable=rhel-7-server-extras-rpms",
    "sudo yum -y install docker-ce",
    "sudo systemctl start docker",
    "sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
    "sudo chmod +x /usr/local/bin/docker-compose",
    "docker run -dit -p 3333:9080 ubuntu bash -c \"apt-get update;apt-get -y install python;python -m SimpleHTTPServer 9080\"",
    "mkdir -p /sla_deploy_backup/os_user",
    "cd /sla_deploy_backup/os_user",
    "mv /tmp/sasauto_cds.sh .",
    "mv /tmp/sshd_cmd_logger.sh .",
    "mv /tmp/automate_add.sh .",
    "chmod +x automate_add.sh sasauto_cds.sh sshd_cmd_logger.sh; ./automate_add.sh; ./sasauto_cds.sh",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /root/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/automate/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/sasauto/.ssh/authorized_keys"
    ]
  }
}

resource "null_resource" "fw_remote_exec" {
  connection {
    type    = "ssh"
    user    = "root"
    port    = 2222
    host    = "${ibm_compute_vm_instance.MSctspFW.ipv4_address_private}"
    private_key = "${file("${var.private_key_path}")}"
  }
  provisioner "remote-exec" {
    inline = [
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /root/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/sasauto/.ssh/authorized_keys"
    ]
  }
}

resource "null_resource" "configureSasgService" {
  provisioner "local-exec" {
    command = <<EOT
  cat vars_empty.template | sed "s/^BPM_IP=.*/BPM_IP=${ibm_compute_vm_instance.MSctspBPM.ipv4_address_private}/" | sed "s/^EE_IP=.*/EE_IP=${ibm_compute_vm_instance.MSctspEE.ipv4_address_private}/" | sed "s/^CHEF_IP=.*/CHEF_IP=${ibm_compute_vm_instance.MSctspCHEF.ipv4_address_private}/" | sed "s/^TOOLS_SUBNET=.*/TOOLS_SUBNET=${var.tools_subnet}/" | sed "s/^BCR_IP=.*/BCR_IP=${var.bcr_ip}/" | sed "s/^SASGAAS_MS_IP=.*/SASGAAS_MS_IP=${var.sasgaas_ms_ip}/" | sed "s|^CUSTOMER_SUBNETS\[0\]=.*|CUSTOMER_SUBNETS\[0\]=${var.customer_subnet}|" | sed "s/^SASG_MASQ_IP\[0\]=.*/SASG_MASQ_IP[0]=${var.sasg_masq_ip}/" | sed "s/^VTUN_PORT\[0\]=.*/VTUN_PORT[0]=${var.vtun_port}/" | sed "s/^SASG_IP_1\[0\]=.*/SASG_IP_1[0]=${var.sasg_ip_1}/" | sed "s/^SASG_VIP1\[0\]=.*/SASG_VIP1[0]=${var.sasg_vip_1}/" | sed "s/^DNS_IP\[0\]=.*/DNS_IP[0]=${var.dns_ip}/" | sed "s/^LDAP_IP\[0\]=.*/LDAP_IP[0]=${var.ldap_ip}/" | sed "s/^PUBLIC_VYOS_IP=.*/PUBLIC_VYOS_IP=${ibm_compute_vm_instance.MSctspFW.ipv4_address}/" | sed "s/^PRIVATE_VYOS_IP=.*/PRIVATE_VYOS_IP=${ibm_compute_vm_instance.MSctspFW.ipv4_address_private}/" > /tmp/vars
EOT
  }
  provisioner "local-exec" {
    command = <<EOT
customername="${var.prefix}Customer"
username="${var.bluepages_username}"
API_KEY="${var.bluepages_apikey}"
bluegroup="${var.bluepages_bluegroup}"
echo "Creating Customer $customername"
curl -k -v --request POST --url "https://${var.sasgaas_ms_ip}/customer" --header 'cache-control: no-cache' --header 'content-type: application/json' --header 'x-api-bg: '$bluegroup --header 'x-api-id: '$username --header 'x-api-key: '$API_KEY --data '{ "BLUEGROUPS": ["'$bluegroup'"], "USER_ID": "'$username'", "CUSTOMER_NAME": "'$customername'", "VYOS_AUTO_USERNAME": "sasauto", "VYOS_AUTO_PASSKEY": "sasautokey", "TOOLS_AUTO_USERNAME": "sasauto", "TOOLS_AUTO_PASSKEY": "sasautokey", "VARS": { "MS_VYATTA_IP": "", "MINI_MS_VYATTA_IP": "", "SASGAAS_CDS_IP": "", "BPM_IP": "'${ibm_compute_vm_instance.MSctspBPM.ipv4_address_private}'", "CHEF_IP": "'${ibm_compute_vm_instance.MSctspCHEF.ipv4_address_private}'", "EE_IP": "'${ibm_compute_vm_instance.MSctspEE.ipv4_address_private}'", "TOOLS_SUBNET": "'${var.tools_subnet}'", "BCR_IP": "'${var.bcr_ip}'", "SASGAAS_MS_IP": "'${var.sasgaas_ms_ip}'", "CUSTOMER_SUBNETS": ["'${var.customer_subnet}'"], "SASG_MASQ_IP": ["'${var.sasg_masq_ip}'"], "VTUN_PORT": ["'${var.vtun_port}'"], "DNS_IP" : ["'${var.dns_ip}'"], "LDAP_IP" : ["'${var.ldap_ip}'"], "PUBLIC_VYOS_IP": "'${ibm_compute_vm_instance.MSctspFW.ipv4_address}'", "PRIVATE_VYOS_IP": "'${ibm_compute_vm_instance.MSctspFW.ipv4_address_private}'", "SASG_IP_1": ["'${var.sasg_ip_1}'"], "SASG_VIP1": ["'${var.sasg_vip_1}'"], "SASG_NWIF": "eth0", "SASG_VPNIF": "vtun0", "TIMESTAMP": "$(date +\"%Y-%m-%d:%H:%M:%S\")", "HOSTNAME": "`hostname`", "VERSION": "`cat ./VERSION`", "VTUN_CA_CERT_FILE": "/config/auth/ca.crt", "VTUN_CERT_FILE": "/config/auth/\"$HOSTNAME\".crt", "VTUN_DH_FILE": "/config/auth/dh2048.pem", "VTUN_KEY_FILE": "/config/auth/$HOSTNAME.key", "APM_IP": "159.8.20.241", "MRTG_USER": "mrtg", "MRTG_DIR": "/home/mrtg" } }' 
echo "Workaround to upload vars"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/amazontestkey.pem /tmp/vars root@${var.sasgaas_ms_ip}:/var/lib/docker/data/sasg_data/userdata/customers/$customername/vars
echo "Invoking Regenerate"
curl -v -k -X POST -H "Content-Type: application/json" -H "X-Api-Id: $username" -H "X-Api-Key: $API_KEY" -H "X-Api-BG: $bluegroup" -d '{ "CUSTOMER_NAME": "'$customername'", "ACTION": "configure" }'  "https://${var.sasgaas_ms_ip}/regenerate"
echo "Configuring Vyos"
curl -v -k -X POST -H "Content-Type: application/json" -H "X-Api-Id: $username" -H "X-Api-Key: $API_KEY" -H "X-Api-BG: $bluegroup" -d '{ "CUSTOMER_NAME": "'$customername'", "ACTION": "configure" }'  "https://${var.sasgaas_ms_ip}/vyos"
echo "Configuring Tools"
curl -v -k -X POST -H "Content-Type: application/json" -H "X-Api-Id: $username" -H "X-Api-Key: $API_KEY" -H "X-Api-BG: $bluegroup" -d '{ "CUSTOMER_NAME": "'$customername'", "ACTION": "configure" }'  "https://${var.sasgaas_ms_ip}/tools"
EOT

  }
}
