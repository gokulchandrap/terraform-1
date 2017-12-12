output "svg_bpm_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_bpm.ipv4_address_private}"
}

output "svg_ee_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_ee.ipv4_address_private}"
}

output "svg_chef_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_chef.ipv4_address_private}"
}

output "svg_vyos_ipv6"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_vyos.ipv6_address}"
}

output "svg_vyos_ipv4"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_vyos.ipv4_address}"
}

output "svg_vyos_ipv4_address_private"  {
  value = "${ibm_compute_vm_instance.vm_ctsp_vyos.ipv4_address_private}"
}

