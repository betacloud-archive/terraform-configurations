resource "openstack_compute_keypair_v2" "key_management" {
  name = var.name
}

resource "openstack_compute_instance_v2" "instance" {
  name              = var.name
  availability_zone = var.availability_zone
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = openstack_compute_keypair_v2.key_management.name

  network { port = openstack_networking_port_v2.port_management.id }

  user_data = <<-EOT
#cloud-config
package_update: true
write_files:
  - content: |
      ${indent(6, file("docker/files/bootstrap.sh"))}
    path: /opt/bootstrap.sh
    permissions: 0755
  - content: |
      ${indent(6, file("docker/files/bootstrap.yml"))}
    path: /opt/bootstrap.yml
    permissions: '0644'
runcmd:
  - "/opt/bootstrap.sh"
final_message: "The system is finally up, after $UPTIME seconds"
power_state:
  mode: reboot
  condition: True
EOT

}
