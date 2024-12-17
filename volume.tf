resource "oci_core_volume" "create_volume" {
  count               =  "${var.num}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index < var.num/(var.slave_num+1) ? 0 : 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.name}-${count.index}"
  size_in_gbs         = "${var.volume_size}"
  vpus_per_gb         = "${var.volume_vpus}"
}

resource "oci_core_volume_attachment" "each_volume_attachment" {
  count           =  "${var.num}"
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.Create-cluster[count.index].id
  volume_id       = oci_core_volume.create_volume[count.index].id
}
