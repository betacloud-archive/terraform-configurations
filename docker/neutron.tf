resource "openstack_networking_secgroup_v2" "secgroup_management" {
  name        = "${var.name}-default"
  description = "Default security group for ${var.name}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_management.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_management.id
}

data "openstack_networking_network_v2" "net_management" {
  name = var.net_management
}

resource "openstack_networking_port_v2" "port_management" {
  name               = "port_management_${var.name}"
  network_id         = data.openstack_networking_network_v2.net_management.id
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup_management.id,
  ]
}

resource "openstack_networking_floatingip_v2" "floatingip_management" {
  description = "Management address for ${var.name}"
  pool        = var.public
}

resource "openstack_networking_floatingip_associate_v2" "floatingip_management_association" {
  floating_ip = openstack_networking_floatingip_v2.floatingip_management.address
  port_id     = openstack_networking_port_v2.port_management.id
}
