# compartment.tf
locals {
	name_prefix = "COMP"
	time_f      = formatdate("HHmmss", timestamp())
}

resource "oci_identity_compartment" "my_new_compartment" {
	#Required
	compartment_id = var.compartment_id
	description    = var.description
	name           = format("%s-%s-%s", local.name_prefix, var.name, local.time_f)
	#Optional
	# defined_tags  = var.defined_tags
	# enable_delete = var.enable_delete
	# freeform_tags = var.freeform_tags
}
