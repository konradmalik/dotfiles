output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = oci_core_instance.a1.private_ip
}

output "public_ip" {
  description = "The public IP address assigned to the instance."
  value       = oci_core_instance.a1.public_ip
}

output "instance_id" {
  description = "The OCID of the instance that was created"
  value       = oci_core_instance.a1.id
}

output "ipv6_address" {
  description = "The IPv6 address assigned to the instance."
  value       = var.assign_ipv6_address ? oci_core_ipv6.ipv6_address[0].ip_address : null
}
 