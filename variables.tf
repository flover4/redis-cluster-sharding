variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "vcn_id" {}
variable "subnet_id" {}
variable "assign_public_ip" {
  default = "false"
}
variable "shape" {
  default = "VM.Standard.E4.Flex"
}
variable "cluster_placement_group_ocid" {}
variable "ocpus" {}
variable "memory_in_gbs" {}
variable "image_id" {}
variable "ssh_public_key" {}
variable "user" {}
variable "volume_size" {}
variable "volume_vpus" {}

variable "name" {}
variable "num" {}
variable "slave_num" {}
variable "redis_version" {}
variable "pass" {
  default = ""
}

provider "oci" {
  tenancy_ocid         = "${var.tenancy_ocid}"
  region               = "${var.region}"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id       = "${var.tenancy_ocid}"
}
