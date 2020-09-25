output "management_address" {
  value = openstack_networking_floatingip_v2.floatingip_management.address
}

output "management_key" {
  value = openstack_compute_keypair_v2.key_management.private_key
}

output "management_secgroup" {
  value = openstack_networking_secgroup_v2.secgroup_management.id
}

resource "local_file" "id_rsa" {
  filename          = ".id_rsa.${var.configuration}.${var.name}.${var.environment}"
  file_permission   = "0600"
  sensitive_content = openstack_compute_keypair_v2.key_management.private_key
}

resource "local_file" "management_address" {
  filename        = ".management_address.${var.configuration}.${var.name}.${var.environment}"
  file_permission = "0644"
  content         = "MANAGEMENT_ADDRESS=${openstack_networking_floatingip_v2.floatingip_management.address}\n"
}
