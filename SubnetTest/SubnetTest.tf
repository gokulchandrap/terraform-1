provider ibm {
}

# slcli subnet create private 8 2105029
resource "ibm_subnet" "test" {
  type = "Static"
  private = true
  ip_version = 4
  capacity = 8
  vlan_id = 2105029
}

# Use a built-in function cidrhost with index 0.
output "first_ip_address" {
  value = "${cidrhost(ibm_subnet.test.subnet,0)}"
}
output "subnet_id" {
  value = "${ibm_subnet.test.id}"
}

