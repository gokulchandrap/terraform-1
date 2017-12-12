#provider "softlayer" {
#  username = "${var.username}"
#  api_key  = "${var.api_key}"
#}
provider "ibm" {
}

data "softlayer_ssh_key" "public_key" {
    label = "ctspkey"
}

#CTSP Sasg
resource "ibm_compute_vm_instance" "ctsp_sasg1" {
  hostname             = "${var.prefix}-sasg1-${var.datacenter}"
  datacenter           = "${var.datacenter}"
  private_subnet       = "${var.private_subnet}"
  tags                 = "${var.tags}"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code_redhat}"
  network_speed        = "${var.network_speed}"
  cores                = "${var.cores}"
  memory               = "${var.memory}"
  hourly_billing       = "${var.hourly_billing}"
  local_disk           = "${var.local_disk}"
  ssh_key_ids          = ["${data.softlayer_ssh_key.public_key.id}"]
}

