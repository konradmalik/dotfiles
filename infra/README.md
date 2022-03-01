# Oracle Cloud Always Free Ampere A1 Compute instance

Terraform module which creates an Always Free Ampere A1 Compute instance in Oracle Cloud.

This module attempts to limit inputs to valid values for the Always Free instance.

Use of this module does not guarantee usage falls within the Always Free tier. For example,
other instances could be using some of the Always Free allocation.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_oci"></a> [oci](#requirement_oci)                   | >=4.37.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_oci"></a> [oci](#provider_oci) | >=4.37.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                  | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [oci_core_instance.a1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance)                                     | resource    |
| [oci_core_ipv6.ipv6_address](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_ipv6)                                   | resource    |
| [oci_core_images.os](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images)                                      | data source |
| [oci_core_vnic_attachments.a1_vnic_attachments](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_vnic_attachments) | data source |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                                                                                                             | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_assign_ipv6_address"></a> [assign_ipv6_address](#input_assign_ipv6_address)                | Whether or not an IPv6 address should be assigned to the instance. Requires a subnet with IPv6 enabled. Defaults to `false`.                                                                                                                            | `bool`         | `false` |    no    |
| <a name="input_assign_public_ip"></a> [assign_public_ip](#input_assign_public_ip)                         | Whether or not a public IP should be assigned to the instance. Defaults to `null` which assigns a public IP based on whether the subnet is public or private. The Free Tier only includes 2 public IP addresses so you may need to set this to `false`. | `bool`         | `null`  |    no    |
| <a name="input_availability_domain"></a> [availability_domain](#input_availability_domain)                | The availability domain of the instance.                                                                                                                                                                                                                | `string`       | n/a     |   yes    |
| <a name="input_boot_volume_size_in_gbs"></a> [boot_volume_size_in_gbs](#input_boot_volume_size_in_gbs)    | A custom size for the boot volume. Must be between 50 and 200. If not set, defaults to the size of the image which is around 46 GB.                                                                                                                     | `any`          | `null`  |    no    |
| <a name="input_compartment_id"></a> [compartment_id](#input_compartment_id)                               | The OCID of the compartment containing the instance.                                                                                                                                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_hostname"></a> [hostname](#input_hostname)                                                 | The hostname of the instance.                                                                                                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_memory_in_gbs"></a> [memory_in_gbs](#input_memory_in_gbs)                                  | The amount of memory in GB to assign to the instance. Must be between 1 and 24.                                                                                                                                                                         | `number`       | `6`     |    no    |
| <a name="input_nsg_ids"></a> [nsg_ids](#input_nsg_ids)                                                    | A list of Network Security Group OCIDs to attach to the primary vnic.                                                                                                                                                                                   | `list(string)` | `[]`    |    no    |
| <a name="input_ocpus"></a> [ocpus](#input_ocpus)                                                          | The number of OCPUs to assign to the instance. Must be between 1 and 4.                                                                                                                                                                                 | `number`       | `1`     |    no    |
| <a name="input_operating_system"></a> [operating_system](#input_operating_system)                         | The Operating System of the platform image to use. Valid values are "Canonical Ubuntu", "Oracle Linux", or "Oracle Linux Cloud Developer".                                                                                                              | `string`       | n/a     |   yes    |
| <a name="input_operating_system_version"></a> [operating_system_version](#input_operating_system_version) | The version of the Operating System specified in `operating_system`.                                                                                                                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_ssh_authorized_keys"></a> [ssh_authorized_keys](#input_ssh_authorized_keys)                | The public SSH key(s) that should be authorized for the default user.                                                                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)                                              | The OCID of the subnet to create the VNIC in.                                                                                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_user_data"></a> [user_data](#input_user_data)                                              | User data passed to cloud-init when the instance is started. Defaults to `null`.                                                                                                                                                                        | `string`       | `null`  |    no    |

## Outputs

| Name                                                                    | Description                                      |
| ----------------------------------------------------------------------- | ------------------------------------------------ |
| <a name="output_instance_id"></a> [instance_id](#output_instance_id)    | The OCID of the instance that was created        |
| <a name="output_ipv6_address"></a> [ipv6_address](#output_ipv6_address) | The IPv6 address assigned to the instance.       |
| <a name="output_private_ip"></a> [private_ip](#output_private_ip)       | The private IP address assigned to the instance. |
| <a name="output_public_ip"></a> [public_ip](#output_public_ip)          | The public IP address assigned to the instance.  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
