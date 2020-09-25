provider "openstack" {
  cloud = var.environment
}

terraform {
  required_version = ">= 0.12"

  # The "hashicorp" namespace is the new home for the HashiCorp-maintained
  # provider plugins.
  #
  # source is not required for the hashicorp/* namespace as a measure of
  # backward compatibility for commonly-used providers, but recommended for
  # explicitness.
  #
  # source is required for providers in other namespaces, to avoid ambiguity.

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    openstack = {
      source = "terraform-providers/openstack"
    }
  }
}

module "docker" {
  source = "../docker"

  availability_zone = var.availability_zone
  configuration = var.configuration
  flavor = var.flavor
  image = var.image
  name = var.name
  net_management = var.net_management
  public = var.public

}

resource "null_resource" "bootstrap" {

  depends_on = [module.docker]

  connection {
    host = module.docker.management_address
    private_key = module.docker.management_key
    user = var.username
  }

  provisioner "file" {
    source      = "keycloak/service"
    destination = "/home/${var.username}"
  }
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = module.docker.management_secgroup
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_https_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = module.docker.management_secgroup
}
