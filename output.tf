output "master_id" {
  value = oci_core_instance.ic_pub_vm-A.id
}

output "worker_id" {
  value = oci_core_instance.ic_pub_vm-B.id
}
