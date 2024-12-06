variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "Example"
}

variable "cidr_block" {
  type = string
}

variable "ssh_keypair_pub_path" {
  type    = string
  default = "id_example.pub"
}

variable "remote_peer_name" {
  type    = string
  default = "idOS"
}

variable "remote_account_id" {
  type = string
}

variable "remote_peer_region" {
  type = string
}

variable "remote_vpc_id" {
  type = string
}

variable "remote_cidr_block" {
  type = string
}
