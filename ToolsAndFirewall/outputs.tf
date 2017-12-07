output "svg_bpm_ipv4_address_private"  {
  value = "${softlayer_virtual_guest.MSctspBPM.ipv4_address_private}"
}

output "svg_chef_ipv4_address_private"  {
  value = "${softlayer_virtual_guest.MSctspCHEF.ipv4_address_private}"
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

