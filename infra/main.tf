data "oci_core_images" "os" {
  compartment_id           = var.compartment_id
  operating_system         = var.operating_system
  operating_system_version = var.operating_system_version
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "a1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.hostname
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    hostname_label   = var.hostname
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    nsg_ids          = var.nsg_ids
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.os.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = var.user_data
  }
}

data "oci_core_vnic_attachments" "a1_vnic_attachments" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.a1.id
}

resource "oci_core_ipv6" "ipv6_address" {
  count   = var.assign_ipv6_address ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.a1_vnic_attachments.vnic_attachments[0].vnic_id
}
