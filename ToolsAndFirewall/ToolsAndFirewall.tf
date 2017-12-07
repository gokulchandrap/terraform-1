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
}

resource "null_resource" "bpm_remote_exec" {
  connection {
    type    = "ssh"
    user    = "root"
    port    = 22
    host    = "${softlayer_virtual_guest.MSctspBPM.ipv4_address_private}"
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
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
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
    host    = "${softlayer_virtual_guest.MSctspCHEF.ipv4_address_private}"
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
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
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
    host    = "${softlayer_virtual_guest.MSctspEE.ipv4_address_private}"
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
    inline = ["sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine",
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
    host    = "${softlayer_virtual_guest.MSctspFW.ipv4_address_private}"
    private_key = "${file("${var.private_key_path}")}"
  }
  provisioner "remote-exec" {
    inline = [
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /root/.ssh/authorized_keys",
    "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCexyYRvubWy3VxaPF+7KDnmD/knav1/ftaWQmJc4zrpaYFfhAd1lvPKGe/GEHJ0N36CRHBiT6GK4c6PjNdiqNS+yXdlA61hZyvq0KOc7iDO/JlsRJ02H7kds6Yh6t/IT+WojESFGibCFhpaQrgvDxkLv7bt4/qAzJjmz9obOqEP37eU56uCoTuSK9fxhOhmpj5aKbqDzgyamq5MiXXx+HjOTPmWFuZY88si8Y/pDegQ34bJsDAGHAJ3yuEmCnREt1WqfKCOSgnPQPHe3Q5TdlHOJ545AytyHnIO0VdDwkpHrzPSmQ6oJSCk979OakRehr06WQSsw99Yj/hWCUJxt9j ameyatayade@ameyas-mbp.watson.ibm.com' >> /home/sasauto/.ssh/authorized_keys"
    ]
  }
}
