output "svg_bpm_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.MSctspBPM.ipv4_address_private}"
}

output "svg_chef_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.MSctspCHEF.ipv4_address_private}"
}

output "svg_fw_ipv6"  {
  value = "${ibm_compute_vm_instance.MSctspFW.ipv6_address}"
}

output "svg_fw_ipv4"  {
  value = "${ibm_compute_vm_instance.MSctspFW.ipv4_address}"
}

output "svg_fw_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.MSctspFW.ipv4_address_private}"
}

