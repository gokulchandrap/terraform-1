#CTSP Sasg
resource "softlayer_virtual_guest" "ctsp_sasg1" {
  hostname             = "${var.prefix}ctspSasgOne"
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
}

