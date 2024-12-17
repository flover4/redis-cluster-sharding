// Create a private endpoint
resource "oci_resourcemanager_private_endpoint" "rms_private_endpoint" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.name}"
  description    = "${var.name}-ep"
  vcn_id         = "${var.vcn_id}"
  subnet_id      = "${var.subnet_id}"
}

// Resolves the private IP of the customer's private endpoint to a NAT IP. 
data "oci_resourcemanager_private_endpoint_reachable_ip" "rms_pe_reachable_ip_address" {
  count               =  "${var.num}"
  private_endpoint_id = oci_resourcemanager_private_endpoint.rms_private_endpoint.id
  private_ip          = oci_core_instance.Create-cluster[count.index].private_ip
}