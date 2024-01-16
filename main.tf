# main.tf
locals {
  name_prefix = "COMP"
  time_f      = formatdate("HHmmss", timestamp())
}

############################################
# VCN
############################################

resource "oci_core_vcn" "k3s_vcn" {
  #Required
  compartment_id = var.compartment_id
  cidr_blocks    = var.vcn1.cidr_blocks
  dns_label      = var.vcn1.dns_label
  #Optional
  display_name = var.vcn1.display_name
}

############################################
# Public Subnet
############################################

resource "oci_core_subnet" "subnetA_pub" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  cidr_block     = var.subnetA_pub.cidr_block
  dns_label      = var.subnetA_pub.dns_label
  #Optional
  display_name               = var.subnetA_pub.display_name
  prohibit_public_ip_on_vnic = !var.subnetA_pub.is_public
  prohibit_internet_ingress  = !var.subnetA_pub.is_public
}

############################################
# Internet Gateways and NAT Gateways
############################################

resource "oci_core_internet_gateway" "the_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = var.internet_gateway_A.display_name
}


############################################
# Route Tables
############################################

resource "oci_core_default_route_table" "the_route_table" {
  #Required
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_vcn.k3s_vcn.default_route_table_id
  # Optional
  display_name = var.subnetA_pub.route_table.display_name
  dynamic "route_rules" {
    for_each = [true]
    content {
      destination       = var.internet_gateway_A.ig_destination
      description       = var.subnetA_pub.route_table.description
      network_entity_id = oci_core_internet_gateway.the_internet_gateway.id
    }
  }
}

############################################
# Security List
############################################
resource "oci_core_security_list" "k3s_vcn_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = var.k3s_vcn_security_list.display_name
  dynamic "ingress_security_rules" {
  	for_each = var.k3s_vcn_security_list.ingress_security_rules
	iterator = rule
    content {
      description = rule.value["description"]
      protocol    = rule.value["protocol"]
      source      = rule.value["source"]
	  tcp_options {
	  	min = rule.value["destination_port_range"].min
		max = rule.value["destination_port_range"].max
      }

    }
  }
  dynamic "egress_security_rules" {
    for_each = var.k3s_vcn_security_list.egress_security_rules
	iterator = rule
    content {
      description = rule.value["description"]
      protocol    = rule.value["protocol"]
      destination = rule.value["destination"]

    }
  }
}

# ############################################
# # Compute Instance
# ############################################

resource "oci_core_instance" "ic_pub_vm-A" {
  compartment_id      = var.compartment_id
  shape               = var.ic_pub_vm_A.shape.name
  availability_domain = var.ic_pub_vm_A.availability_domain
  display_name        = var.ic_pub_vm_A.display_name

  source_details {
    source_id   = var.ic_pub_vm_A.image_ocid
    source_type = "image"
	boot_volume_size_in_gbs = var.ic_pub_vm_A.boot_volume.size_in_gbs
	boot_volume_vpus_per_gb = var.ic_pub_vm_A.boot_volume.vpus_per_gb
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.ic_pub_vm_A.shape.memory_in_gbs
      ocpus         = var.ic_pub_vm_A.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnetA_pub.id
    assign_private_dns_record = true
    assign_public_ip          = var.ic_pub_vm_A.create_vnic_details.assign_public_ip
    hostname_label            = var.ic_pub_vm_A.create_vnic_details.hostname_label
  }

  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}" 
	user_data = "${base64encode(file("./cloud-config.yaml"))}"
  }
}

resource "oci_core_instance" "ic_pub_vm-B" {
  compartment_id      = var.compartment_id
  shape               = var.ic_pub_vm_B.shape.name
  availability_domain = var.ic_pub_vm_B.availability_domain
  display_name        = var.ic_pub_vm_B.display_name

  source_details {
    source_id   = var.ic_pub_vm_B.image_ocid
    source_type = "image"
	boot_volume_size_in_gbs = var.ic_pub_vm_B.boot_volume.size_in_gbs
	boot_volume_vpus_per_gb = var.ic_pub_vm_B.boot_volume.vpus_per_gb
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = var.ic_pub_vm_B.shape.memory_in_gbs
      ocpus         = var.ic_pub_vm_B.shape.ocpus
    }
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnetA_pub.id
    assign_private_dns_record = true
    assign_public_ip          = var.ic_pub_vm_B.create_vnic_details.assign_public_ip
    hostname_label            = var.ic_pub_vm_B.create_vnic_details.hostname_label
  }

  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}" 
	user_data = "${base64encode(file("./cloud-config.yaml"))}"
  }
}
