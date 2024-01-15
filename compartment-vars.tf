# compartment-vars.tf
#Required
variable "compartment_id" {
	description = "Compartment OCID"
	type        = string
}
variable "description" {
	description = "Compartment Description"
	type        = string
}
variable "name" {
	description = "Compartment Name"
	type        = string
}
