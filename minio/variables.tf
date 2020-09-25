variable "configuration" {
  default = "minio"
  type    = string
}

variable "environment" {
  default = "betacloud"
  type    = string
}

variable "name" {
  default = "docker"
  type    = string
}

variable "username" {
  default = "ubuntu"
  type    = string
}

variable "image" {
  default = "Ubuntu 18.04"
  type    = string
}

variable "flavor" {
  default = "1C-1GB-10GB"
  type    = string
}

variable "availability_zone" {
  default = "south-2"
  type    = string
}

variable "public" {
  default = "external"
  type    = string
}

variable "net_management" {
  default = "net-to-external-testbed"
  type    = string
}
