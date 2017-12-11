provider ibm {
}

resource "ibm_subnet" "test" {
  type = "Static"
  private = true
  ip_version = 4
  capacity = 4
  vlan_id = 1545437
}

# Use a built-in function cidrhost with index 0.
output "first_ip_address" {
  value = "${cidrhost(ibm_subnet.test.subnet,0)}"
}

