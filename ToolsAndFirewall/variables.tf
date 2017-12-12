#variable "username" {
#   description = "Softlayer user name"
#}
#
#variable "api_key" {
#   description = "Softlayer API Key"
#}

variable "bluepages_username" {
   description = "Bluepages username"
}

variable "bluepages_apikey" {
   description = "Bluepages API Key"
}

variable "bluepages_bluegroup" {
   description = "Bluepages Bluegroup"
}

variable "prefix" {
   description = "Hostname prefix <project>[<Enviroment Type>-]>[-<Account c Code>|<Spare Account Name>]"
   default     = "ctsp-d-aak1"
}

variable "vtun_port" {
   description = "VTUN_PORT"
   default     = "443"
}

variable "customer_subnet" {
   description = "Customer Subnet"
   default     = "10.190.87.128/26"
}

variable "tools_subnet" {
   description = "Tools Subnet"
   default     = "255.255.255.192"
}

variable "bcr_ip" {
   description = "Current default GW of the tools server before pointing to vyos"
   default     = "10.190.87.129"
}

variable "sasgaas_ms_ip" {
   description = "Private IP Address of the VM running Sasg Automation Web App"
   default     = "10.190.87.161"
}

variable "sasg_masq_ip" {
   description = "Public IP Address of the Master SASG VM"
}

variable "sasg_ip_1" {
   description = "Private sasg customer ip address"
}

variable "sasg_vip_1" {
   description = "Softlayer Portable IP"
   default     = "10.186.95.5"
}

variable "dns_ip" {
   description = "DNS"
   default     = "8.8.8.8"
}

variable "ldap_ip" {
   description = "Ldap ip address"
   default     = "10.153.81.2"
}

variable "bpm_hostname" {
   description = "BPM hostname"
   default     = "bpm"
}

variable "chef_hostname" {
   description = "Chef hostname"
   default     = "chef"
}

variable "ee_hostname" {
   description = "EE hostname"
   default     = "ee"
}

variable "fw_hostname" {
   description = "Firewall hostname"
   default     = "vyos1"
}

variable "fw_hostname_2" {
   description = "Firewall hostname"
   default     = "vyos2"
}

variable "datacenter" {
   description = "This is the datacenter, Ours is D.C. 07"
   default     = "wdc07"
}

variable "private_subnet" {
   description = "This is the subnet that was given to us, everything should be on the same one"
   default     = "10.190.87.128/26"
}

variable "tags" {
   description = "This is the tags"
   default     = ["ctsp"]
}

variable "fw_image_id" {
  description = "Firewall image ID: SASTeam_SasFW_Redhat_7.4_Image_V4"
  default     = "1764243"
}

variable "tools_image_id" {
  description = "Tools image ID: SLA_Default_Linux_Image"
  default     = "1775961"
}

variable "domain" {
  description = "I think this should always be ibm"
  default     = "ibm.com"
}

variable "private_key_path" {
  description = "Enter the path to your public key"
  default     = "/home/terraform/amazontestkey.pem"
}

#variable "public_key_path" {
#  description = "Enter the path to your public key \n For instance mine is: /Users/matthewxstaffelbach/.ssh/amazontestkey.pub"
#  default     = "/home/terraform/amazontestkey.pub"
#}

variable "hourly_billing" {
  description = "boolean"
  default     = true
}

variable "local_disk" {
  description = "boolean"
  default     = true
}

variable "memory" {
  description = "describe your variable"
  default     = 1024
}

variable "disks" {
  description = "2 disks, one for image ID & and second is requried for booting"
  default     = [100,100]}

variable "cores" {
  description = "describe your variable"
  default     = 1
}

variable "network_speed" {
  description = "describe your variable"
  default     = 1000
}

variable "os_reference_code_redhat" {
  description = "redhat 7 64bit OS"
  default     = "REDHAT_7_64"
}

