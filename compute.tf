	/* Instances */
	resource "oci_core_instance" "Create-cluster" {
	  count               =  "${var.num}"	  
	#Multi-ADs
	availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index < var.num/(var.slave_num+1) ? 0 : 1],"name")}"

	  fault_domain        = "FAULT-DOMAIN-3"
	  compartment_id      = "${var.compartment_ocid}"
	  display_name        = "${var.name}-${count.index}"
	  shape               = "${var.shape}"

	  shape_config {
		memory_in_gbs             = "${var.memory_in_gbs}"
		ocpus                     = "${var.ocpus}"
	#	baseline_ocpu_utilization = "BASELINE_1_2"
	  }

	  availability_config {

        #Optional
        is_live_migration_preferred = true
        recovery_action             = "RESTORE_INSTANCE"
    }	

	  source_details {
		source_type = "image"
		source_id   = "${var.image_id}"
	  }
	 
	  create_vnic_details {
		subnet_id        = "${var.subnet_id}"
		display_name     = "${var.name}-${count.index}"
		assign_public_ip = "${var.assign_public_ip}"
	  }

	  launch_options {
		network_type     = "VFIO"
	  }

	  metadata = {
		ssh_authorized_keys = "${var.ssh_public_key}"
	  }

	  timeouts {
		create = "60m"
	  }

	}

	resource "local_file" "inventory" {
	  depends_on = [oci_core_volume_attachment.each_volume_attachment]
	  content        = "${templatefile("inventory.cfg", {		
		redis_master    = data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe_reachable_ip_address[0],
		redis_node  = slice(data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe_reachable_ip_address, 1, length(data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe_reachable_ip_address))
		})
	  }"
	  filename      = "${path.module}/ansible/inventory"
	}

	resource "null_resource" "runplaybook" {
	  depends_on = [local_file.inventory]	  
      triggers = {
        always_run = "${timestamp()}"
      }
	  provisioner "local-exec" {		
		command = "chmod 600 ${path.module}/ansible/ssh_private_key.key && export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook --timeout 3000 -u ${var.user} -i '${path.module}/ansible/inventory' --private-key '${path.module}/ansible/ssh_private_key.key' -e 'redis_version=${var.redis_version} pass=${var.pass} slave_num=${var.slave_num} user=${var.user} memory_max=${ceil(var.memory_in_gbs * 1024 * 1024 * 1024 * 0.75)}' ${path.module}/ansible/deploy.yml"
	  }
	}